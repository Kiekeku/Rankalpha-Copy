import json
import os
import logging
from logging.handlers import RotatingFileHandler
import re
import time
from typing import Any, List, Optional, Type, Union, Dict

from openai import AsyncOpenAI
try:
    import httpx  # used for direct PDF downloads
except Exception:  # pragma: no cover - optional
    httpx = None  # type: ignore

from mcp_agent.workflows.llm.augmented_llm import (
    AugmentedLLM,
    MessageParamT,
    MessageT,
    ModelT,
    RequestParams,
)
from mcp.types import CallToolRequest, CallToolRequestParams
from mcp_agent.logging.logger import get_logger

# Optional Redis support for cross-process caching
try:  # pragma: no cover - optional dependency
    from redis.asyncio import Redis as AsyncRedis  # type: ignore
except Exception:  # pragma: no cover - fallback when redis is unavailable
    AsyncRedis = None  # type: ignore


def _extract_json_obj(text: str) -> Optional[dict[str, Any]]:
    try:
        return json.loads(text)
    except Exception:
        pass
    # Fallback: try to extract the largest {...} block by trimming to first '{' and last '}'
    first = text.find("{")
    last = text.rfind("}")
    if first != -1 and last != -1 and last > first:
        candidate = text[first : last + 1]
        try:
            return json.loads(candidate)
        except Exception:
            pass
    # As a last attempt, the first simple {...} match
    m = re.search(r"\{[\s\S]*?\}", text)
    if m:
        try:
            return json.loads(m.group(0))
        except Exception:
            return None
    return None


class Gpt5ResponsesPlannerLLM(AugmentedLLM[MessageParamT, str]):
    """Planner LLM using the OpenAI Responses API for GPT‑5 family.

    - Sends a single developer message (instruction) and a user message.
    - Avoids system messages entirely.
    - Implements simple JSON parsing for structured outputs.
    """

    provider: str | None = "OpenAI"
    logger = get_logger(__name__)

    # ---- Global tool usage counters (per-process) ----
    # Counts by tool name across all agents
    _TOOL_COUNTS: Dict[str, int] = {}
    # Nested counts by agent -> tool name
    _AGENT_TOOL_COUNTS: Dict[str, Dict[str, int]] = {}

    @classmethod
    def record_tool_use(cls, agent_name: str, tool_name: str) -> None:
        try:
            key = str(tool_name or "unknown").strip()
            cls._TOOL_COUNTS[key] = int(cls._TOOL_COUNTS.get(key, 0)) + 1
            a = str(agent_name or "unknown").strip()
            by_agent = cls._AGENT_TOOL_COUNTS.get(a) or {}
            by_agent[key] = int(by_agent.get(key, 0)) + 1
            cls._AGENT_TOOL_COUNTS[a] = by_agent
        except Exception:
            pass

    @classmethod
    def get_tool_usage_snapshot(cls, reset: bool = False) -> dict:
        """Return a snapshot dict of tool usage counts; optionally reset counters."""
        snapshot = {
            "by_tool": dict(cls._TOOL_COUNTS),
            "by_agent": {k: dict(v) for k, v in cls._AGENT_TOOL_COUNTS.items()},
        }
        if reset:
            try:
                cls._TOOL_COUNTS.clear()
                cls._AGENT_TOOL_COUNTS.clear()
            except Exception:
                pass
        return snapshot

    @classmethod
    def log_tool_usage_summary(cls, logger: logging.Logger | None = None, reset: bool = True) -> None:
        try:
            snap = cls.get_tool_usage_snapshot(reset=False)
            if not logger:
                logger = logging.getLogger("sentiment.prompts")
            # Summaries sorted desc
            by_tool = sorted(snap.get("by_tool", {}).items(), key=lambda x: (-int(x[1] or 0), x[0]))
            lines = ["TOOL USAGE SUMMARY (this process):"]
            if by_tool:
                lines.append("- By tool:")
                for name, cnt in by_tool:
                    lines.append(f"  • {name}: {cnt}")
            by_agent = snap.get("by_agent", {}) or {}
            if by_agent:
                lines.append("- By agent:")
                for agent, d in sorted(by_agent.items()):
                    parts = ", ".join(f"{n}:{c}" for n, c in sorted(d.items(), key=lambda x: (-int(x[1] or 0), x[0])))
                    lines.append(f"  • {agent}: {parts}")
            logger.info("\n".join(lines))
        except Exception:
            pass

    def _settings(self):  # lazy load centralized settings
        s = getattr(self, "__settings", None)
        if s is not None:
            return s
        try:
            from apps.common.src.settings import Settings as _S  # type: ignore
            s = _S()
        except Exception:
            # attempt to add repo root
            try:
                from pathlib import Path as _Path
                import sys as _sys
                root = _Path(__file__).resolve().parents[4]
                if str(root) not in _sys.path:
                    _sys.path.insert(0, str(root))
                from apps.common.src.settings import Settings as _S  # type: ignore
                s = _S()
            except Exception:
                s = None
        setattr(self, "__settings", s)
        return s

    @staticmethod
    def _coerce_evaluation_from_text(text: str) -> Optional[dict[str, Any]]:
        """Parse evaluator free-text into a structured object with string-digit rating.

        String mapping required by schema: "0"=POOR, "1"=FAIR, "2"=GOOD, "3"=EXCELLENT
        """
        if not isinstance(text, str) or not text.strip():
            return None
        import re as _re
        # Extract rating label if present
        rating = None
        m = _re.search(r"Quality\s*rating\s*:\s*([A-Za-z_\-]+)", text, _re.IGNORECASE)
        if not m:
            m = _re.search(r"OVERALL\s*RATING\s*:\s*([A-Za-z_\-]+)", text, _re.IGNORECASE)
        if m:
            rating = m.group(1).strip().upper().replace(" ", "_")
        # Extract needs improvement hint
        needs = None
        m2 = _re.search(r"Improvement\s*needed\s*:\s*(true|false|yes|no)", text, _re.IGNORECASE)
        if m2:
            needs = m2.group(1).strip().lower() in {"true", "yes"}
        # Fallbacks
        if rating is None and needs is not None:
            rating = "FAIR" if needs else "GOOD"
        if rating is None:
            return None
        rating_map = {"POOR": "0", "FAIR": "1", "GOOD": "2", "EXCELLENT": "3"}
        rating_code = rating_map.get(rating, "1")
        return {
            "rating": rating_code,
            "feedback": text,
            "needs_improvement": bool(needs) if needs is not None else True,
        }

    @staticmethod
    def _normalize_evaluation_data(data: dict) -> dict:
        """Normalize evaluator JSON to match string-digit enum schema expected by the model.

        - rating: convert labels or ints to string digits ("0".."3")
        - needs_improvement: coerce from string to boolean
        """
        out = dict(data) if isinstance(data, dict) else {}
        if "rating" in out:
            r = out["rating"]
            if isinstance(r, str):
                r_str = r.strip().upper()
                label_map = {"POOR": "0", "FAIR": "1", "GOOD": "2", "EXCELLENT": "3"}
                if r_str in label_map:
                    out["rating"] = label_map[r_str]
                elif r_str in {"0", "1", "2", "3"}:
                    out["rating"] = r_str
            elif isinstance(r, (int, float)):
                # Coerce numeric to string digit within 0..3
                try:
                    ival = int(r)
                    if 0 <= ival <= 3:
                        out["rating"] = str(ival)
                except Exception:
                    out["rating"] = "1"
        if "needs_improvement" in out and isinstance(out["needs_improvement"], str):
            out["needs_improvement"] = out["needs_improvement"].strip().lower() in {"1", "true", "yes", "on"}
        return out

    @staticmethod
    def _to_snake(s: str) -> str:
        s2 = s.replace("-", " ").replace("/", " ").replace(".", " ")
        parts = [p for p in s2.strip().lower().split() if p]
        return "_".join(parts) if parts else s.strip()

    @classmethod
    def _normalize_plan_data(cls, data: dict) -> dict:
        """Normalize common planner JSON variants to match Orchestrator schema.

        - Enforce steps: list of { description: str, tasks: list[{ description, agent }] }
        - Map agent aliases to known names: research_quality_controller, financial_analyst, report_writer
        - Coerce is_complete to boolean; default False
        - Rename 'subtasks' -> 'tasks' if needed
        """
        if not isinstance(data, dict):
            return {"steps": [], "is_complete": False}
        out = dict(data)
        steps = out.get("steps")
        if not isinstance(steps, list):
            steps = []
        normalized_steps: list[dict] = []
        for st in steps:
            if not isinstance(st, dict):
                continue
            desc = st.get("description")
            tasks = st.get("tasks")
            if tasks is None and isinstance(st.get("subtasks"), list):
                tasks = st.get("subtasks")
            if not isinstance(tasks, list):
                tasks = []
            normalized_tasks: list[dict] = []
            for t in tasks:
                if not isinstance(t, dict):
                    continue
                tdesc = t.get("description")
                agent = t.get("agent")
                if isinstance(agent, str):
                    agen_lower = agent.lower()
                    snake = cls._to_snake(agent)
                    if ("evaluatoroptimizerllm" in agen_lower) or ("research_quality" in agen_lower):
                        agent_fixed = "research_quality_controller"
                    elif ("financial" in agen_lower and "analyst" in agen_lower):
                        agent_fixed = "financial_analyst"
                    elif ("report" in agen_lower and "writer" in agen_lower):
                        agent_fixed = "report_writer"
                    else:
                        agent_fixed = snake
                else:
                    agent_fixed = "research_quality_controller"
                normalized_tasks.append({"description": tdesc, "agent": agent_fixed})
            normalized_steps.append({"description": desc, "tasks": normalized_tasks})
        out["steps"] = normalized_steps
        is_complete_raw = out.get("is_complete", None)
        if is_complete_raw is None:
            for alt in ("isComplete", "complete", "completed", "done", "status"):
                if alt in out:
                    is_complete_raw = out[alt]
                    break

        if isinstance(is_complete_raw, str):
            norm = is_complete_raw.strip().lower()
            is_complete = norm in {"true","1","yes","on","complete","completed","done","finished","success"}
        elif isinstance(is_complete_raw, bool):
            is_complete = is_complete_raw
        else:
            is_complete = False

        # If the plan returns no remaining steps, default to complete
        if not steps and is_complete is False:
            is_complete = True

        out["is_complete"] = is_complete
        return out

    @classmethod
    def _normalize_plan_with_context(cls, data: dict, context_text: str | None) -> dict:
        """Temporarily disabled context-based completion heuristics.

        This method now defers to _normalize_plan_data without using the context
        to avoid premature completion or step skipping.
        """
        return cls._normalize_plan_data(data)

    async def _call_openai(
        self,
        message: Union[str, MessageParamT, List[MessageParamT]],
        request_params: RequestParams,
        response_model: Optional[Type[ModelT]] = None,
        previous_response_id: Optional[str] = None,
    ) -> tuple[str, Optional[str]]:
        # Simple per-instance cache for MCP tool calls to avoid repeated searches/fetches
        try:

            # --- Inside _call_openai(), near the start (before bridge loop) ---
            # Add these locals so increments never NameError and flags are available everywhere
            tool_calls_total_local = 0
            cache_enabled = bool(getattr(self._settings(), "sentiment_tool_cache", True))
            max_pdf_chars = None
            try:
                max_pdf_chars = int(getattr(self._settings(), "sentiment_pdf_extract_max_chars", 200_000))
            except Exception:
                max_pdf_chars = 200_000


            if not hasattr(self, "_mcp_tool_cache"):
                self._mcp_tool_cache: dict[str, dict[str, Any]] = {}
            if not hasattr(self, "_mcp_tool_cache_ttl"):
                s = self._settings()
                ttl = None
                try:
                    ttl = int(getattr(s, "sentiment_tool_cache_ttl_seconds", 0)) if s else None
                except Exception:
                    ttl = None
                self._mcp_tool_cache_ttl = ttl if ttl and ttl > 0 else 86400
            # Initialize Redis client lazily if available
            if AsyncRedis is not None and not hasattr(self, "_redis_client"):
                s = self._settings()
                url = getattr(s, "redis_url", None) if s else None
                host = getattr(s, "redis_host", None) or "localhost"
                port_raw = str(getattr(s, "redis_port", "6379") or "6379")
                db_raw = str(getattr(s, "redis_db", "0") or "0")
                password = getattr(s, "redis_password", None) if s else None
                try:
                    if url:
                        self._redis_client = AsyncRedis.from_url(url, decode_responses=True)  # type: ignore[attr-defined]
                    else:
                        self._redis_client = AsyncRedis(  # type: ignore[call-arg]
                            host=host,
                            port=int(port_raw),
                            db=int(db_raw),
                            password=password,
                            decode_responses=True,
                        )
                except Exception:
                    self._redis_client = None
        except Exception:
            pass
        # Toggle for capturing full prompts/responses to logs
        s = self._settings()
        log_prompts = bool(getattr(s, "sentiment_log_prompts", False))
        if log_prompts:
            try:
                self.logger.setLevel(logging.DEBUG)
            except Exception:
                pass
        prompt_logger = logging.getLogger("sentiment.prompts")
        if log_prompts:
            prompt_logger.setLevel(logging.DEBUG)
            # Attach a rotating file handler directly to this logger to
            # guarantee capture even if root level is INFO.
            try:
                log_path = getattr(s, "sentiment_log_file", None)
                if log_path:
                    # De-duplicate by filename
                    already = False
                    for h in prompt_logger.handlers:
                        if isinstance(h, RotatingFileHandler) and getattr(h, "baseFilename", None) == log_path:
                            already = True
                            break
                    if not already:
                        fh = RotatingFileHandler(log_path, maxBytes=10 * 1024 * 1024, backupCount=5, encoding="utf-8")
                        fh.setLevel(logging.DEBUG)
                        fh.setFormatter(logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s"))
                        prompt_logger.addHandler(fh)
                        # Avoid double logging via root when a dedicated handler is present
                        prompt_logger.propagate = False
            except Exception:
                pass
        # Visibility hook: confirm this path is active in the logs
        try:
            prompt_logger.debug(
                "[PROMPT_HOOK] agent=%s log_prompts=%s",
                getattr(self.agent, "name", "unknown"),
                str(log_prompts),
            )
        except Exception:
            pass
        # Collect messages as Responses API input
        messages: List[dict[str, Any]] = []
        # If caller provided a prebuilt conversation (list of role/content dicts), use it directly
        if isinstance(message, list) and all(
            isinstance(m, dict) and m.get("role") and m.get("content") is not None for m in message
        ):
            messages = list(message)
            if self.instruction and not any(m.get("role") == "developer" for m in messages):
                messages.insert(0, {
                    "role": "developer",
                    "content": [{"type": "input_text", "text": self.instruction}],
                })
        else:
            if self.instruction:
                messages.append({
                    "role": "developer",
                    "content": [{"type": "input_text", "text": self.instruction}],
                })

            if isinstance(message, str):
                messages.append({
                    "role": "user",
                    "content": [{"type": "input_text", "text": message}],
                })
            elif isinstance(message, list):
                # Best-effort: stringify complex inputs
                joined = "\n".join(str(m) for m in message)
                messages.append({
                    "role": "user",
                    "content": [{"type": "input_text", "text": joined}],
                })
            else:
                messages.append({
                    "role": "user",
                    "content": [{"type": "input_text", "text": str(message)}],
                })

        model = request_params.model or (self.default_request_params.model if self.default_request_params else None)
        if not model:
            raise ValueError("Planner model not specified")

        # Map token + reasoning params
        kwargs: dict[str, Any] = {"model": model, "input": messages, "stream": False}
        # If the caller provides a previous_response_id, continue that Responses session
        if previous_response_id:
            kwargs["previous_response_id"] = previous_response_id
        # Default higher token budgets for verbose worker agents
        agent_name = str(getattr(self.agent, "name", "")).lower()
        default_tokens = 2048
        try:
            if agent_name == "financial_analyst":
                v = getattr(s, "sentiment_analyst_max_tokens", None)
                default_tokens = int(v) if v else 8192
            elif agent_name == "report_writer":
                v = getattr(s, "sentiment_writer_max_tokens", None)
                default_tokens = int(v) if v else 8192
        except Exception:
            pass
        if hasattr(request_params, "maxTokens") and request_params.maxTokens:
            kwargs["max_output_tokens"] = int(request_params.maxTokens)
            if kwargs["max_output_tokens"] < default_tokens:
                kwargs["max_output_tokens"] = default_tokens
        else:
            # Provide a sane default to avoid truncation
            kwargs["max_output_tokens"] = default_tokens

        # Reasoning effort from context.openai if present
        try:
            effort = getattr(self.context.config.openai, "reasoning_effort", None)
            if effort:
                kwargs["reasoning"] = {"effort": effort}
        except Exception:
            pass

        # Map MCP tools to Responses function tools
        try:
            tools_resp = await self.agent.list_tools()
            tools_list: list[dict[str, Any]] = []
            # Cache schemas to guide argument augmentation (e.g., fetch PDF handling)
            self._tool_schemas: dict[str, dict[str, Any]] = {}
            for t in getattr(tools_resp, "tools", []) or []:
                name = getattr(t, "name", None)
                if not name:
                    continue
                schema = getattr(t, "inputSchema", {}) or {}
                try:
                    self._tool_schemas[str(name)] = schema
                except Exception:
                    pass
                tool_def = {
                    "type": "function",
                    "name": name,
                    "description": getattr(t, "description", "") or "",
                    "parameters": schema,
                }
                tools_list.append(tool_def)
            if tools_list:
                kwargs["tools"] = tools_list
                # Avoid OpenAI's multi_tool_use.parallel aggregator; bridge tools individually
                # by not advertising parallel tool calls support.
                # (Some SDKs/models auto-infer parallel usage; this reduces aggregator usage.)
        except Exception:
            pass

        # Prefer JSON-only responses when a structured model is requested
        if response_model is not None:
            try:
                schema = response_model.model_json_schema()
                self._disallow_additional_props(schema)
                # _disallow_additional_props(schema)
                kwargs["response_format"] = {
                    "type": "json_schema",
                    "json_schema": {
                        "name": response_model.__name__,
                        "strict": True,
                        "schema": schema,
                    },
                }
                # Do not set temperature: some gpt-5 models don't support it
            except Exception:
                # last-resort fallback
                kwargs["response_format"] = {"type": "json_object"}
        else:
            # Encourage JSON-only outputs only for the analyst to keep structure.
            try:
                if agent_name == "financial_analyst":
                    kwargs["response_format"] = {"type": "json_object"}
            except Exception:
                pass

        # Build client from context config
        config = getattr(self.context, "config", None)
        api_key = getattr(getattr(config, "openai", None), "api_key", None)
        base_url = getattr(getattr(config, "openai", None), "base_url", None)
        client = AsyncOpenAI(api_key=api_key, base_url=base_url) if base_url else AsyncOpenAI(api_key=api_key)

        # Log request (without secrets)
        try:
            safe_kwargs = {k: (v if k not in {"input"} else f"messages[{len(v)}]") for k, v in kwargs.items()}
            agent_name = getattr(self.agent, "name", "unknown")
            self.logger.debug(
                "BEGIN OAI Responses.create",
                data={
                    "agent": agent_name,
                    "model": kwargs.get("model"),
                    "max_output_tokens": kwargs.get("max_output_tokens"),
                    "reasoning": kwargs.get("reasoning"),
                    "messages_count": len(messages),
                    "response_format": kwargs.get("response_format"),
                },
            )
            self.logger.debug("Responses.create kwargs:", data=safe_kwargs)
            if log_prompts:
                try:
                    msgs_json = json.dumps(messages, ensure_ascii=False)
                except Exception:
                    msgs_json = str(messages)
                self.logger.debug(
                    "PROMPT messages",
                    data={
                        "agent": agent_name,
                        "model": kwargs.get("model"),
                        "messages_json": msgs_json,
                    },
                )
                # Also log prompts via standard logger to ensure file capture
                try:
                    prompt_logger.debug("[PROMPT] agent=%s model=%s messages=%s", agent_name, kwargs.get("model"), msgs_json)
                except Exception:
                    pass
        except Exception:
            pass

        # Create response, with fallback if SDK does not support response_format
        try:
            resp = await client.responses.create(**kwargs)  # type: ignore[arg-type]
        except TypeError as e:
            # Older SDKs may not accept response_format; retry without it
            if "response_format" in str(e):
                try:
                    _ = kwargs.pop("response_format", None)
                    self.logger.debug(
                        "Responses.create: retrying without response_format (unsupported by SDK)",
                        data={"had_response_format": True},
                    )
                except Exception:
                    pass
                resp = await client.responses.create(**kwargs)  # type: ignore[arg-type]
            else:
                raise

        # Helper: augment fetch args (PDF-aware) based on tool schema
        def _augment_fetch_args(tool_name: str, args: dict[str, Any] | None) -> dict[str, Any]:
            a: dict[str, Any] = dict(args or {})
            try:
                if "fetch" not in (tool_name or "").lower():
                    return a
                # Identify potential URL field from schema
                schema = (getattr(self, "_tool_schemas", {}) or {}).get(tool_name) or {}
                props = (schema.get("properties") if isinstance(schema, dict) else None) or {}
                url_key = None
                for cand in ("url", "uri", "href"):
                    if cand in props or cand in a:
                        url_key = cand
                        break
                if not url_key and any(k in a for k in ("url", "uri", "href")):
                    for k in ("url", "uri", "href"):
                        if k in a:
                            url_key = k
                            break
                url_val = a.get(url_key) if url_key else None
                is_pdf = False
                if isinstance(url_val, str):
                    u = url_val.lower()
                    is_pdf = ".pdf" in u or "content=pdf" in u or "format=pdf" in u or "download=pdf" in u
                # Ensure minimum max_length
                fl = getattr(self._settings(), "sentiment_fetch_max_length", None)
                try:
                    min_len = int(fl) if fl else 5000
                except Exception:
                    min_len = 5000
                if "max_length" in props or "max_length" in a:
                    try:
                        if int(a.get("max_length", 0) or 0) < min_len:
                            a["max_length"] = min_len
                    except Exception:
                        a["max_length"] = min_len
                # If PDF, hint the server to return plain text if supported
                if is_pdf and isinstance(props, dict):
                    if "extract_text" in props:
                        a.setdefault("extract_text", True)
                    if "as_text" in props:
                        a.setdefault("as_text", True)
                    if "format" in props:
                        # Common pattern: format: "text" | "html" | "json"
                        a.setdefault("format", "text")
                    if "mime" in props:
                        a.setdefault("mime", "text/plain")
                    if "encoding" in props and not a.get("encoding"):
                        a["encoding"] = "utf-8"
                return a
            except Exception:
                return a

        # --- Replace your _pdf_to_markdown with a streaming version + length cap ---
        async def _pdf_to_markdown(url: str) -> Optional[str]:
            try:
                if httpx is None:
                    return None
                timeout = httpx.Timeout(30.0, connect=15.0)
                headers = {"User-Agent": "Mozilla/5.0 (compatible; RankAlpha/1.0)"}

                import os as _os
                from pathlib import Path as _Path
                from datetime import datetime as _dt

                base_dir = getattr(self._settings(), "sentiment_data_dir", None) or "/tmp"
                tmp_dir = _Path(base_dir) / "pdf_tmp"
                tmp_dir.mkdir(parents=True, exist_ok=True)
                fname = _dt.now().strftime("pdf_%Y%m%d_%H%M%S_%f.pdf")
                fpath = tmp_dir / fname

                # Stream to disk to avoid loading entire file in memory
                async with httpx.AsyncClient(follow_redirects=True, timeout=timeout) as client:
                    async with client.stream("GET", url, headers=headers) as r:
                        r.raise_for_status()
                        ct = (r.headers.get("content-type") or "").lower()
                        # optional: basic size guard
                        cl = r.headers.get("content-length")
                        if cl and int(cl) > 50 * 1024 * 1024:
                            return None  # bail on >50MB by policy; adjust as needed
                        with fpath.open("wb") as w:
                            async for chunk in r.aiter_bytes():
                                w.write(chunk)

                # Quick validation by magic header if possible
                head = fpath.read_bytes(5)
                if not head.startswith(b"%PDF") and "pdf" not in ct:
                    return None

                # Prefer PyMuPDF markdown
                try:
                    import pymupdf4llm as _pdf4llm  # type: ignore
                    md = _pdf4llm.to_markdown(str(fpath))
                    if isinstance(md, str) and md.strip():
                        pass
                    else:
                        md = None
                except Exception:
                    md = None

                # Fallback to pdfminer text
                if not md:
                    try:
                        from pdfminer.high_level import extract_text as _extract_text  # type: ignore
                        txt = _extract_text(str(fpath))
                        if txt and txt.strip():
                            md = "# Extracted PDF Text\n\n" + txt
                    except Exception:
                        md = None

                if not md:
                    return None

                # Hard cap length to avoid blowing the model context
                nonlocal max_pdf_chars  # uses the variable defined above
                if max_pdf_chars and len(md) > max_pdf_chars:
                    md = md[:max_pdf_chars] + f"\n\n[Truncated at {max_pdf_chars} chars]"

                return md
            except Exception:
                return None


        # Bridge Responses function calls to MCP tools (with per-instance caching)
        try:
            while True:
                outputs = getattr(resp, "output", []) or []
                fn_outputs: list[dict[str, Any]] = []
                for item in outputs:
                    if getattr(item, "type", "") != "function_call":
                        continue
                    name = getattr(item, "name", None)
                    call_id = getattr(item, "call_id", None)
                    args_raw = getattr(item, "arguments", None)
                    try:
                        args = json.loads(args_raw or "{}") if isinstance(args_raw, str) else (args_raw or {})
                    except Exception:
                        args = {}
                    # Special handling for OpenAI's aggregator tool which requests multiple tool calls in parallel
                    try:
                        nlower = str(name or "").lower()
                        if nlower in {"multi_tool_use.parallel", "multi_tool_use.serial", "functions.multi_tool_use.parallel"}:
                            nested = []
                            # Common schema: { "tool_calls": [ {"id": "call_...", "name": "fetch", "arguments": {...}}, ...] }
                            if isinstance(args, dict):
                                if isinstance(args.get("tool_calls"), list):
                                    nested = args.get("tool_calls") or []
                                elif isinstance(args.get("calls"), list):
                                    nested = args.get("calls") or []
                            for nc in nested:
                                try:
                                    nid = nc.get("id") or nc.get("call_id")
                                    nname = nc.get("name")
                                    nargs = nc.get("arguments")
                                    if isinstance(nargs, str):
                                        try:
                                            nargs = json.loads(nargs)
                                        except Exception:
                                            pass
                                    if not nid or not nname:
                                        continue
                                    # If this nested call is a fetch for a PDF, directly convert to markdown
                                    try:
                                        url_val = None
                                        if isinstance(nargs, dict):
                                            for k in ("url", "uri", "href"):
                                                if k in nargs:
                                                    url_val = nargs[k]
                                                    break
                                        if isinstance(nname, str) and ("fetch" in nname.lower()) and isinstance(url_val, str):
                                            low = url_val.lower()
                                            if any(s in low for s in (".pdf", "content=pdf", "format=pdf", "download=pdf")):
                                                md = await _pdf_to_markdown(url_val)
                                                if md:
                                                    payload = {"text": md, "isError": False, "source": "pdf-markdown","truncated": len(md) >= max_pdf_chars}
                                                    fn_outputs.append({"type": "function_call_output", "call_id": nid, "output": json.dumps(payload, ensure_ascii=False)})
                                                    tool_calls_total += 1
                                                    # Also cache result
                                                    try:
                                                        if cache_enabled:
                                                            # Build a local cache key specific to nested call
                                                            nkey = f"{nname}:{json.dumps(nargs, sort_keys=True, ensure_ascii=False)}"
                                                            if getattr(self, "_redis_client", None) is not None:
                                                                rkey = f"sentiment:tool_cache:{nkey}"
                                                                ttl = int(float(getattr(self, "_mcp_tool_cache_ttl", 86400)))
                                                                await self._redis_client.setex(rkey, ttl, json.dumps(payload, ensure_ascii=False))
                                                            # in-memory
                                                            try:
                                                                self._mcp_tool_cache[nkey] = {"payload": payload, "expires": time.time() + float(getattr(self, "_mcp_tool_cache_ttl", 86400))}
                                                            except Exception:
                                                                pass
                                                    except Exception:
                                                        pass
                                                    tool_calls_total_local += 1
                                                    continue
                                    except Exception:
                                        pass
                                    # Ensure reasonable fetch length by default
                                    try:
                                        if isinstance(nname, str) and isinstance(nargs, dict):
                                            nargs = _augment_fetch_args(nname, nargs)
                                    except Exception:
                                        pass
                                    # Execute the MCP tool for this nested call
                                    req = CallToolRequest(method="tools/call", params=CallToolRequestParams(name=nname, arguments=nargs or {}))
                                    res = await self.call_tool(request=req, tool_call_id=str(nid))
                                    try:
                                        self.record_tool_use(getattr(self.agent, "name", "unknown"), str(nname))
                                    except Exception:
                                        pass
                                    out_lines: list[str] = []
                                    for c in getattr(res, "content", []) or []:
                                        try:
                                            out_lines.append(getattr(c, "text", None) or str(c))
                                        except Exception:
                                            pass
                                    payload = {"text": "\n".join(out_lines), "isError": getattr(res, "isError", False)}
                                    fn_outputs.append({"type": "function_call_output", "call_id": nid, "output": json.dumps(payload, ensure_ascii=False)})
                                    tool_calls_total += 1
                                except Exception:
                                    continue
                            # Aggregator handled; skip normal single-tool path
                            continue
                    except Exception:
                        # Fallback to normal handling if aggregator parsing fails
                        pass
                    # Compute a canonical cache key (ignore purely runtime knobs)
                    cache_enabled = bool(getattr(self._settings(), "sentiment_tool_cache", True))
                    cache_key = None
                    if cache_enabled:
                        try:
                            # Remove non-result-affecting keys
                            args_for_key = dict(args)
                            for k in list(args_for_key.keys()):
                                if k in {"timeout", "debug"}:
                                    args_for_key.pop(k, None)
                            cache_key = f"{name}:{json.dumps(args_for_key, sort_keys=True, ensure_ascii=False)}"
                        except Exception:
                            cache_key = None
                    # Ensure reasonable fetch length and PDF hints
                    try:
                        # If this call is a fetch for PDF, try to convert to markdown directly
                        if isinstance(name, str):
                            url_val = None
                            if isinstance(args, dict):
                                for k in ("url", "uri", "href"):
                                    if k in args:
                                        url_val = args[k]
                                        break
                            if ("fetch" in name.lower()) and isinstance(url_val, str):
                                low = url_val.lower()
                                if any(s in low for s in (".pdf", "content=pdf", "format=pdf", "download=pdf")):
                                    md = await _pdf_to_markdown(url_val)
                                    if md:
                                        payload = {"text": md, "isError": False, "source": "pdf-markdown", "truncated": len(md) >= max_pdf_chars}
                                        # respond immediately without calling the MCP tool
                                        fn_outputs.append({"type": "function_call_output", "call_id": call_id, "output": json.dumps(payload, ensure_ascii=False)})
                                        tool_calls_total += 1
                                        # Cache result
                                        if cache_enabled and cache_key:
                                            try:
                                                if getattr(self, "_redis_client", None) is not None:
                                                    rkey = f"sentiment:tool_cache:{cache_key}"
                                                    ttl = int(float(getattr(self, "_mcp_tool_cache_ttl", 86400)))
                                                    await self._redis_client.setex(rkey, ttl, json.dumps(payload, ensure_ascii=False))
                                            
                                                self._mcp_tool_cache[cache_key] = {"payload": payload, "expires": time.time() + float(getattr(self, "_mcp_tool_cache_ttl", 86400))}
                                            except Exception:
                                                pass
                                        # Skip the standard tool execution for this call
                                        tool_calls_total_local += 1
                                        continue
                            # otherwise normal augmentation
                            args = _augment_fetch_args(name, args)
                    except Exception:
                        pass
                    cached_payload: Optional[dict[str, Any]] = None
                    # Prefer Redis cache if available
                    if cache_key and getattr(self, "_redis_client", None) is not None:
                        try:
                            rkey = f"sentiment:tool_cache:{cache_key}"
                            val = await self._redis_client.get(rkey)
                            if val:
                                cached_payload = json.loads(val)
                        except Exception:
                            cached_payload = None
                    # Fallback to in-memory cache
                    if cache_key and cached_payload is None and getattr(self, "_mcp_tool_cache", None) is not None:
                        entry = self._mcp_tool_cache.get(cache_key)
                        now = time.time()
                        if entry and isinstance(entry, dict):
                            try:
                                if float(entry.get("expires", 0)) >= now:
                                    cached_payload = entry.get("payload")
                                else:
                                    self._mcp_tool_cache.pop(cache_key, None)
                            except Exception:
                                pass
                    if cached_payload is None:
                        # Execute MCP tool
                        req = CallToolRequest(
                            method="tools/call",
                            params=CallToolRequestParams(name=name, arguments=args),
                        )
                        res = await self.call_tool(request=req, tool_call_id=str(call_id))
                        try:
                            self.record_tool_use(getattr(self.agent, "name", "unknown"), str(name))
                        except Exception:
                            pass
                        out_lines: list[str] = []
                        for c in getattr(res, "content", []) or []:
                            try:
                                out_lines.append(getattr(c, "text", None) or str(c))
                            except Exception:
                                pass
                        payload = {
                            "text": "\n".join(out_lines),
                            "isError": getattr(res, "isError", False),
                        }
                        if cache_key and cache_enabled:
                            # Store in Redis (preferred)
                            try:
                                if getattr(self, "_redis_client", None) is not None:
                                    rkey = f"sentiment:tool_cache:{cache_key}"
                                    ttl = int(float(getattr(self, "_mcp_tool_cache_ttl", 86400)))
                                    await self._redis_client.setex(rkey, ttl, json.dumps(payload, ensure_ascii=False))
                            except Exception:
                                pass
                            # Always back up in local memory in case Redis is unavailable later
                            try:
                                self._mcp_tool_cache[cache_key] = {
                                    "payload": payload,
                                    "expires": time.time() + float(getattr(self, "_mcp_tool_cache_ttl", 86400)),
                                }
                            except Exception:
                                pass
                    else:
                        payload = cached_payload
                    fn_outputs.append(
                        {
                            "type": "function_call_output",
                            "call_id": call_id,
                            "output": json.dumps(payload, ensure_ascii=False),
                        }
                    )
                if not fn_outputs:
                    break
                resp = await client.responses.create(
                    model=model,
                    previous_response_id=getattr(resp, "id", None),
                    input=fn_outputs,
                )
        except Exception:
            # If function-call bridging fails, fall through and try to extract text
            pass

        # Extract text output
        try:
            # Preferred accessor
            text = resp.output_text  # type: ignore[attr-defined]
            # Log response metadata and a preview of output
            try:
                preview = (str(text)[:500] + "…") if text and len(str(text)) > 500 else (str(text) if text else "")
                usage = getattr(resp, "usage", None)
                self.logger.debug(
                    "END OAI Responses.create",
                    data={
                        "agent": getattr(self.agent, "name", "unknown"),
                        "id": getattr(resp, "id", None),
                        "status": getattr(resp, "status", None),
                        "usage": getattr(usage, "model_dump", lambda: None)(),
                        "output_preview": preview,
                    },
                )
                if log_prompts:
                    # Attempt to serialize the full response
                    try:
                        if hasattr(resp, "model_dump_json"):
                            full_json = resp.model_dump_json()
                        elif hasattr(resp, "model_dump"):
                            full_json = json.dumps(resp.model_dump(), ensure_ascii=False)
                        else:
                            # Best-effort stringify
                            full_json = str(resp)
                    except Exception:
                        full_json = str(resp)
                    self.logger.debug(
                        "RESPONSE full",
                        data={
                            "agent": getattr(self.agent, "name", "unknown"),
                            "response_json": full_json,
                        },
                    )
                    # Also write full response via standard logger
                    try:
                        prompt_logger.debug("[RESPONSE] agent=%s id=%s status=%s json=%s", getattr(self.agent, "name", "unknown"), getattr(resp, "id", None), getattr(resp, "status", None), full_json)
                    except Exception:
                        pass
            except Exception:
                pass
            if text:
                rid = None
                try:
                    rid = getattr(resp, "id", None)
                except Exception:
                    rid = None
                return str(text), rid
        except Exception:
            pass

        # Fallback extraction
        try:
            parts = []
            for item in getattr(resp, "output", []) or []:
                role = getattr(item, "role", None)
                for c in getattr(item, "content", []) or []:
                    ctype = getattr(c, "type", None)
                    # Only keep assistant output_text; drop reasoning or other types
                    if ctype == "output_text" and (role in (None, "assistant")):
                        t = getattr(getattr(c, "text", None), "value", None)
                        if t:
                            parts.append(t)
            try:
                joined = "\n".join(parts)
                preview = (joined[:500] + "…") if len(joined) > 500 else joined
                self.logger.debug(
                    "END OAI Responses.create (assembled)",
                    data={
                        "agent": getattr(self.agent, "name", "unknown"),
                        "output_preview": preview,
                    },
                )
                rid = None
                try:
                    rid = getattr(resp, "id", None)
                except Exception:
                    rid = None
                return joined, rid
            except Exception:
                rid = None
                try:
                    rid = getattr(resp, "id", None)
                except Exception:
                    rid = None
                return "\n".join(parts), rid
            self._last_tool_calls = tool_calls_total_local
        except Exception:
            return "", None

    async def generate(
        self,
        message: Union[str, MessageParamT, List[MessageParamT]],
        request_params: RequestParams | None = None,
    ) -> List[str]:
        params = self.get_request_params(request_params)

        # Conversation messages
        conv: List[dict[str, Any]] = []
        if self.instruction:
            conv.append({
                "role": "developer",
                "content": [{"type": "input_text", "text": self.instruction}],
            })

        # Keep user message focused on the task; tool availability is provided via Responses tools
        conv.append({"role": "user", "content": [{"type": "input_text", "text": str(message)}]})

        max_iters = getattr(params, "max_iterations", 10) or 10
        final_text: Optional[str] = None
        tool_calls_total: int = 0
        wrote_file_path: Optional[str] = None
        last_response_id: Optional[str] = None
        for iter_idx in range(max_iters):
            # Call model
            kwargs_params = RequestParams(
                model=params.model,
                maxTokens=params.maxTokens,
                temperature=getattr(params, "temperature", 0.2),
            )
            try:
                self.logger.debug(
                    "LLM iteration start",
                    data={
                        "agent": getattr(self.agent, "name", "unknown"),
                        "iteration": iter_idx + 1,
                        "messages_in_conv": len(conv),
                    },
                )
            except Exception:
                pass
            response_text, rid = await self._call_openai(
                conv,
                kwargs_params,
                previous_response_id=last_response_id,
            )
            last_response_id = rid or last_response_id
            try:
                preview = (response_text[:1000] + "…") if response_text and len(response_text) > 1000 else response_text
                self.logger.debug(
                    "LLM raw response",
                    data={
                        "agent": getattr(self.agent, "name", "unknown"),
                        "iteration": iter_idx + 1,
                        "length": len(response_text or ""),
                        "preview": preview,
                    },
                )
            except Exception:
                pass

            # Treat model's response as final; function-call bridging occurs inside _call_openai
            if response_text and response_text.strip():
                final_text = response_text.strip()
                break

        # Best-effort: if this is the report_writer and no tool write occurred, try to write file directly
        if (final_text and isinstance(final_text, str) and getattr(self, "agent", None)
            and getattr(self.agent, "name", "") == "report_writer"):
            # Attempt to extract OUTPUT_PATH from prior user message
            try:
                path_match = None
                # Search both developer and user messages for an absolute .md path
                for msg in conv:
                    txt = " ".join([p.get("text", "") for p in msg.get("content", []) if p.get("type") == "input_text"])
                    m = re.search(r"(/[^\s\"']+\.md)", txt)
                    if m:
                        path_match = m.group(1)
                        break
                # If still not found, fall back to SENTIMENT_OUTPUT_DIR and a timestamped filename
                if not path_match:
                    try:
                        base_dir = getattr(self._settings(), "sentiment_output_dir", None) or "/data/company_reports"
                        os.makedirs(base_dir, exist_ok=True)
                        from datetime import datetime as _dt
                        ts = _dt.now().strftime("%Y%m%d_%H%M%S")
                        safe_agent = re.sub(r"[^a-z0-9_\-]", "_", getattr(self.agent, "name", "report_writer").lower())
                        path_match = os.path.join(base_dir, f"auto_report_{safe_agent}_{ts}.md")
                    except Exception:
                        pass
                if path_match:
                    # Discover a write-capable filesystem tool
                    tools_resp = await self.agent.list_tools()
                    write_tool = None
                    content_key = None
                    for t in tools_resp.tools:
                        schema = getattr(t, "inputSchema", {}) or {}
                        props = schema.get("properties", {}) if isinstance(schema, dict) else {}
                        keys = {k.lower() for k in props.keys()}
                        if "path" in keys and ("content" in keys or "text" in keys or "data" in keys or "contents" in keys):
                            write_tool = t
                            if "content" in keys:
                                content_key = "content"
                            elif "text" in keys:
                                content_key = "text"
                            elif "contents" in keys:
                                content_key = "contents"
                            else:
                                content_key = "data"
                            break
                    if write_tool and content_key:
                        args = {"path": path_match, content_key: final_text}
                        req = CallToolRequest(method="tools/call", params=CallToolRequestParams(name=write_tool.name, arguments=args))
                        save_res = await self.call_tool(request=req, tool_call_id="resp_tool_save")
                        try:
                            self.record_tool_use(getattr(self.agent, "name", "unknown"), str(write_tool.name))
                        except Exception:
                            pass
                        try:
                            self.logger.debug("Fallback save attempted", data={"tool": write_tool.name, "path": path_match, "isError": getattr(save_res, "isError", False)})
                        except Exception:
                            pass
                        if not getattr(save_res, "isError", False):
                            wrote_file_path = path_match
                            try:
                                self.logger.debug(
                                    "Report saved via filesystem tool",
                                    data={"agent": getattr(self.agent, "name", "unknown"), "path": wrote_file_path},
                                )
                            except Exception:
                                pass
                        else:
                            try:
                                self.logger.warning("Filesystem write failed", data={"tool": getattr(write_tool, "name", None), "path": path_match})
                            except Exception:
                                pass
            except Exception:
                pass
        # Summary line for observability
        tool_calls_total = getattr(self, "_last_tool_calls", 0)
        try:
            agent_name = getattr(self.agent, "name", "unknown")
            summary = {
                "agent": agent_name,
                "tool_calls": tool_calls_total,
                "wrote_file": bool(wrote_file_path),
            }
            if wrote_file_path:
                summary["path"] = wrote_file_path
            self.logger.info("Agent summary", data=summary)
        except Exception:
            pass
        return [final_text or ""]

    @staticmethod
    def _disallow_additional_props(schema: dict) -> None:
        if not isinstance(schema, dict):
            return
        t = schema.get("type")
        if t == "object":
            schema.setdefault("additionalProperties", False)
            props = schema.get("properties", {}) or {}
            for v in props.values():
                Gpt5ResponsesPlannerLLM._disallow_additional_props(v)
            # Ensure "required" is populated if missing
            if "required" not in schema and props:
                schema["required"] = list(props.keys())
        elif t == "array":
            items = schema.get("items")
            if isinstance(items, dict):
                Gpt5ResponsesPlannerLLM._disallow_additional_props(items)

    async def generate_str(
        self,
        message: Union[str, MessageParamT, List[MessageParamT]],
        request_params: RequestParams | None = None,
    ) -> str:
        params = self.get_request_params(request_params)
        result = await self.generate(message, params)
        return result[0] if result else ""

    async def generate_structured(
        self,
        message: Union[str, MessageParamT, List[MessageParamT]],
        response_model: Type[ModelT],
        request_params: RequestParams | None = None,
    ) -> ModelT:
        params = self.get_request_params(request_params)
        # Ensure prompt logger is wired for file capture
        prompt_logger = logging.getLogger("sentiment.prompts")
        try:
            log_path = getattr(self._settings(), "sentiment_log_file", None)
            if log_path:
                prompt_logger.setLevel(logging.DEBUG)
                # Attach if missing for this logger
                has_handler = any(
                    isinstance(h, RotatingFileHandler) and getattr(h, "baseFilename", None) == log_path
                    for h in prompt_logger.handlers
                )
                if not has_handler:
                    fh = RotatingFileHandler(log_path, maxBytes=10 * 1024 * 1024, backupCount=5, encoding="utf-8")
                    fh.setLevel(logging.DEBUG)
                    fh.setFormatter(logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s"))
                    prompt_logger.addHandler(fh)
                    prompt_logger.propagate = False
        except Exception:
            pass
        # First attempt with enforced JSON response_format
        text, _rid = await self._call_openai(message, params, response_model=response_model)
        # Log raw text preview to the prompt logger for visibility
        try:
            prev = (text[:1000] + "…") if isinstance(text, str) and len(text) > 1000 else text
            prompt_logger.debug("[PLANNER_FIRST_TEXT] agent=%s preview=%s", getattr(self.agent, "name", "unknown"), prev)
        except Exception:
            pass
        model_fields = getattr(response_model, "model_fields", {}) or {}
        data = _extract_json_obj(text) or {}
        if isinstance(data, dict):
            try:
                if ("steps" in model_fields) and ("is_complete" in model_fields):
                    data = self._normalize_plan_data(data)
                if {"rating", "needs_improvement"}.issubset(set(model_fields.keys())):
                    data = self._normalize_evaluation_data(data)
                return response_model.model_validate(data)  # type: ignore[attr-defined]
            except Exception as e:
                try:
                    prompt_logger.debug("[STRUCT_VALIDATE_FAIL_FIRST] agent=%s error=%s keys=%s", getattr(self.agent, "name", "unknown"), str(e), list(data.keys()))
                except Exception:
                    pass
        # If evaluator-like model expected, coerce from free text
        if isinstance(model_fields, dict) and {"rating", "feedback","needs_improvement"}.issubset(set(model_fields.keys())):
            minimal_example = (
                '{"rating": "2", "feedback": "short rationale", "needs_improvement": true}'
            )
            retry_prompt = (
                f"{str(message)}\n\nReturn ONLY a valid JSON object with exactly these keys: "
                f"'rating' (\"0\"|\"1\"|\"2\"|\"3\"), 'feedback' (string), 'needs_improvement' (boolean). "
                f"Map: 0=POOR, 1=FAIR, 2=GOOD, 3=EXCELLENT. "
                f"No markdown, no code fences, no extra text. Example: {minimal_example}"
            )
        else:
            # planner fallback (current behavior)
            minimal_example = (
                '{"steps": [{"description": "step description", '
                '"tasks": [{"description": "task", "agent": "financial_analyst"}]}], '
                '"is_complete": true}'
            )
            retry_prompt = (
               f"{str(message)}\n\nReturn ONLY a valid JSON object with exactly these keys: "
                f"'steps' (array) and 'is_complete' (boolean). "
                "If the context shows that 'research_quality_controller', 'financial_analyst', and "
                "'report_writer' have already run and the report was produced/saved, return steps=[] "
                "and is_complete=true. Otherwise list only remaining steps and set is_complete=false. "
                "No markdown, no code fences. Example: " + minimal_example
            )
        # Bump tokens and lower temperature for retry
        retry_params = RequestParams(
            model=params.model,
            maxTokens=max(params.maxTokens or 0, 3072),
            temperature=0.1,
        )
        text2, _rid2 = await self._call_openai(retry_prompt, retry_params, response_model=response_model)
        try:
            prev2 = (text2[:1000] + "…") if isinstance(text2, str) and len(text2) > 1000 else text2
            prompt_logger.debug("[PLANNER_RETRY_TEXT] agent=%s preview=%s", getattr(self.agent, "name", "unknown"), prev2)
        except Exception:
            pass
        data2 = _extract_json_obj(text2) or {}
        if isinstance(data2, dict):
            try:
                if ("steps" in model_fields) and ("is_complete" in model_fields):
                    data2 = self._normalize_plan_data(data2)
                if {"rating", "needs_improvement"}.issubset(set(model_fields.keys())):
                    data2 = self._normalize_evaluation_data(data2)
                return response_model.model_validate(data2)  # type: ignore[attr-defined]
            except Exception as e:
                try:
                    prompt_logger.debug("[STRUCT_VALIDATE_FAIL_RETRY] agent=%s error=%s keys=%s", getattr(self.agent, "name", "unknown"), str(e), list(data2.keys()))
                except Exception:
                    pass
        if isinstance(model_fields, dict) and {"rating", "needs_improvement"}.issubset(set(model_fields.keys())):
            coerced2 = self._coerce_evaluation_from_text(text2)
            if coerced2:
                try:
                    return response_model.model_validate(coerced2)  # type: ignore[attr-defined]
                except Exception:
                    pass
        # Last resort: synthesize a minimal object for known schemas
        if ("steps" in model_fields) and ("is_complete" in model_fields):
            fallback = {
                "steps": [
                    {"description": "Collect high-quality research via research_quality_controller", "tasks": [{"description": "Gather data", "agent": "research_quality_controller"}]},
                    {"description": "Analyze research data", "tasks": [{"description": "Analyze", "agent": "financial_analyst"}]},
                    {"description": "Write and save report", "tasks": [{"description": "Write and save", "agent": "report_writer"}]},
                ],
                "is_complete": False,
            }
        elif {"rating", "needs_improvement"}.issubset(set(model_fields.keys())):
            fallback = {"rating": "1", "feedback": "Auto-coerced from unstructured evaluator text.", "needs_improvement": True}
        else:
            fallback = {}
        try:
            prompt_logger.debug("[STRUCT_FALLBACK] using synthesized object")
            return response_model.model_validate(fallback)  # type: ignore[attr-defined]
        except Exception:
            # Last resort: raise with context
            raise ValueError("Failed to parse structured planner output: validation failed after retry")
