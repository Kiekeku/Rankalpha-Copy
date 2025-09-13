import asyncio
import os
import sys
import json
import re
from types import SimpleNamespace
import time
from datetime import datetime, timedelta
import argparse
import contextlib
import logging
import psycopg2
from psycopg2.extras import execute_values
from pathlib import Path
from mcp_agent.app import MCPApp
from mcp_agent.agents.agent import Agent
from mcp_agent.workflows.orchestrator.orchestrator import Orchestrator
# (planner prompt/model utilities not needed without dry-run)
from mcp_agent.workflows.llm.augmented_llm import RequestParams
from mcp_agent.workflows.llm.augmented_llm_openai import OpenAIAugmentedLLM
from mcp_agent.workflows.evaluator_optimizer.evaluator_optimizer import (
    QualityRating,
)
import shlex
# Ensure repo root is on sys.path when running directly (e.g., `python src/main.py` from apps/sentiment)
def _ensure_repo_root_on_syspath() -> None:
    try:
        import apps  # type: ignore
        return  # already importable
    except ModuleNotFoundError:
        pass
    try:
        this = Path(__file__).resolve()
        for p in this.parents:
            if (p / "apps").exists():
                sys.path.insert(0, str(p))
                break
    except Exception:
        pass

_ensure_repo_root_on_syspath()

from  apps.common.src.logging import get_logger, add_rotating_file_handler
from  apps.common.src.settings import Settings
# Early OpenAI debug bootstrap using centralized Settings before any OpenAI client import
try:
    _settings_early = Settings()
except Exception:
    _settings_early = None
if _settings_early and bool(_settings_early.sentiment_openai_debug):
    os.environ["OPENAI_LOG"] = "debug"
    os.environ["OPENAI_DEBUG"] = "true"
    if not logging.getLogger().handlers:
        logging.basicConfig(
            level=logging.DEBUG,
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        )
    else:
        logging.getLogger().setLevel(logging.DEBUG)
    logging.getLogger("openai").setLevel(logging.DEBUG)
    logging.getLogger("httpx").setLevel(logging.DEBUG)
    logging.getLogger("mcp_agent").setLevel(logging.DEBUG)
    
# Bridge SEC EDGAR user agent from Settings to environment early so MCP subprocesses inherit it
if _settings_early and getattr(_settings_early, "sec_edgar_user_agent", None) and not os.getenv("SEC_EDGAR_USER_AGENT"):
    os.environ["SEC_EDGAR_USER_AGENT"] = str(_settings_early.sec_edgar_user_agent)
# Support running both from local src layout and Docker image layout
try:
    from llm.prompt_loader import load_prompt  # when working dir is the sentiment package root
except ModuleNotFoundError:
    try:
        from apps.sentiment.llm.prompt_loader import load_prompt  # alt absolute path
    except ModuleNotFoundError:
        from apps.sentiment.src.llm.prompt_loader import load_prompt  # local repo path
try:
    # Custom GPT‑5 wrappers
    from llm.gpt5_planner_llm import Gpt5PlannerLLM
    from llm.gpt5_responses_planner_llm import Gpt5ResponsesPlannerLLM
except ModuleNotFoundError:
    try:
        from apps.sentiment.llm.gpt5_planner_llm import Gpt5PlannerLLM
        from apps.sentiment.llm.gpt5_responses_planner_llm import Gpt5ResponsesPlannerLLM
    except ModuleNotFoundError:
        from apps.sentiment.src.llm.gpt5_planner_llm import Gpt5PlannerLLM
        from apps.sentiment.src.llm.gpt5_responses_planner_llm import Gpt5ResponsesPlannerLLM

# Local evaluator-optimizer subclass that avoids duplicating evaluator criteria in user prompts
try:
    from llm.evaluator_optimizer_llm import EvaluatorOptimizerLLMNoDup
except ModuleNotFoundError:
    try:
        from apps.sentiment.llm.evaluator_optimizer_llm import EvaluatorOptimizerLLMNoDup
    except ModuleNotFoundError:
        from apps.sentiment.src.llm.evaluator_optimizer_llm import EvaluatorOptimizerLLMNoDup

MAX_ITERATIONS = 3

# Default paths; will be overridden from Settings in async_main
DATA_DIR = "/data"
OUTPUT_DIR = os.path.join(DATA_DIR, "company_reports")
SCHEDULE_FILE = Path(os.path.join(DATA_DIR, "analysis_schedule", "analysis_schedule.json"))

# In-memory guard to avoid re-running the same stock multiple times in one process per day
_RECENT_ANALYSIS_BY_STOCK: dict[int, int] = {}

def _today_key() -> int:
    return int(datetime.now().strftime("%Y%m%d"))

def _already_completed_today(stock_key: int) -> bool:
    try:
        return _RECENT_ANALYSIS_BY_STOCK.get(stock_key) == _today_key()
    except Exception:
        return False

def _mark_completed_today(stock_key: int) -> None:
    try:
        _RECENT_ANALYSIS_BY_STOCK[stock_key] = _today_key()
    except Exception:
        pass


async def run_consensus_batch(analyzer_app) -> None:
    """Run a one-off batch of consensus symbols using the new view.

    Honors Settings:
      - sentiment_consensus_min_appearances
      - sentiment_consensus_min_styles
      - sentiment_consensus_limit

    Skips symbols that already have analysis today or already completed in this process.
    """
    settings = Settings()
    logger = get_logger(__name__)

    min_app = int(getattr(settings, "sentiment_consensus_min_appearances", 0) or 0)
    min_styles = int(getattr(settings, "sentiment_consensus_min_styles", 0) or 0)
    limit = int(getattr(settings, "sentiment_consensus_limit", 0) or 0)
    if limit <= 0:
        logger.info("Consensus batch: limit <= 0; skipping")
        return

    def get_db_connection():
        max_retries = 3
        for attempt in range(max_retries):
            try:
                return psycopg2.connect(
                    database=settings.database_name,
                    user=settings.db_username,
                    password=settings.password,
                    host=settings.host,
                    port=settings.port,
                    connect_timeout=30,
                )
            except psycopg2.OperationalError as e:
                if attempt == max_retries - 1:
                    logger.error(f"Consensus: DB connect failed after {max_retries} attempts: {e}")
                    raise
                logger.warning(f"Consensus: DB connect attempt {attempt+1} failed, retrying: {e}")
                time.sleep(2 ** attempt)

    # Fetch top symbols from the consensus view
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        query = (
            "SELECT symbol, company_name FROM v_latest_screener_consensus WHERE 1=1 "
        )
        params = []
        if min_app > 0:
            query += " AND appearances >= %s"
            params.append(min_app)
        if min_styles > 0:
            query += " AND styles_distinct >= %s"
            params.append(min_styles)
        query += " ORDER BY consensus_score DESC LIMIT %s"
        params.append(limit)
        cur.execute(query, tuple(params))
        rows = cur.fetchall()
    finally:
        cur.close()
        conn.close()

    today_key = _today_key()
    processed = 0
    skipped_recent = 0
    for symbol, company_name in rows:
        # Skip if already completed this process
        # Also skip if DB shows latest analysis today
        sym = str(symbol).upper()

        # Lookup stock_key and last date
        conn = get_db_connection()
        cur = conn.cursor()
        try:
            cur.execute("SELECT stock_key FROM dim_stock WHERE UPPER(symbol) = %s", (sym,))
            r = cur.fetchone()
            if not r:
                continue
            stock_key = int(r[0])
            if _already_completed_today(stock_key):
                logger.info(f"Consensus skip {sym}: already completed in this run")
                continue
            cur.execute(
                "SELECT MAX(date_key) FROM fact_ai_stock_analysis WHERE stock_key = %s",
                (stock_key,),
            )
            last_date = cur.fetchone()[0]
        finally:
            cur.close()
            conn.close()

        # Skip if already analyzed within N days
        try:
            skip_window = int(getattr(settings, "sentiment_skip_if_within_days", 1) or 1)
        except Exception:
            skip_window = 1
        if last_date:
            try:
                last_dt = datetime.strptime(str(last_date), "%Y%m%d").date()
                days_ago = (datetime.now().date() - last_dt).days
            except Exception:
                days_ago = 0
        else:
            days_ago = 10**6
        if days_ago < max(skip_window, 1):
            logger.info(
                f"Consensus skip {sym}: last analysis {days_ago} days ago (< {skip_window}d)"
            )
            skipped_recent += 1
            continue

        logger.info(f"Consensus run for {company_name} ({sym})")
        try:
            success = await ai_analysis(company_name, analyzer_app, sym)
        except asyncio.TimeoutError:
            logger.warning(f"Consensus analysis timed out for {sym}; not retrying")
            success = False
        if success:
            _mark_completed_today(stock_key)
            # Persistently remove today's date from schedule for this stock if present
            try:
                remove_date_from_schedule(str(stock_key), datetime.now().date())
            except Exception:
                pass
            processed += 1
    logger.info(
        f"Consensus batch done: processed={processed}, skipped_recent={skipped_recent}, requested={len(rows)}"
    )

def extract_json_block(text: str) -> str:
    match1 = re.search(r"'''json\s*(\{.*?\})\s*'''", text, re.DOTALL)
    match2 = re.search(r"```json\s*(\{.*?\})\s*```", text, re.DOTALL)
    if match1:
        return match1.group(1)
    if match2:
        return match2.group(1)
    raise ValueError("JSON block not found in report")

def get_stock_key(cursor, ticker):
    cursor.execute(
        "SELECT stock_key FROM dim_stock WHERE symbol = %s AND is_active IS TRUE", (ticker,)
    )
    row = cursor.fetchone()
    return row[0] if row else None


SENTIMENT_SOURCE_NAME = "RankAlpha Sentiment AI"


def get_or_create_source_key(cursor, source_name: str = SENTIMENT_SOURCE_NAME, version: str = "1") -> int:
    """Ensure a dim_source entry exists and return its key.

    Uses rankalpha.dim_source explicitly to avoid reliance on search_path.
    """
    try:
        cursor.execute(
            "INSERT INTO rankalpha.dim_source (source_name, version) VALUES (%s, %s) "
            "ON CONFLICT (source_name) DO NOTHING",
            (source_name, version),
        )
    except Exception:
        # Ignore conflicts or transient errors; we will select next
        pass
    cursor.execute(
        "SELECT source_key FROM rankalpha.dim_source WHERE source_name = %s",
        (source_name,),
    )
    row = cursor.fetchone()
    if not row:
        raise RuntimeError(f"Failed to obtain source_key for source '{source_name}'")
    return int(row[0])

def map_trend_key(trend_str: str) -> int | None:
    trend_map = {
        "strong up": 1,
        "slight up": 2,
        "slight down": 3,
        "strong down": 4,
        "strong net sales": 5,
        "slight net sales": 6,
        "slight net buy": 7,
        "strong net buy": 8
    }
    if not trend_str:
        return None
    return trend_map.get(trend_str.lower().strip())


def map_rating_key(rating_str: str) -> int | None:
    rating_map = {
        "strong_buy": 1,
        "buy": 2,
        "neutral": 3,
        "sell": 4,
        "strong_sell": 5
    }
    if not rating_str:
        return None
    return rating_map.get(rating_str.lower().replace(' ', '_').strip())


def map_confidence_key(conf_str: str) -> int | None:
    conf_map = {"low": 1, "medium": 2, "high": 3}
    if not conf_str:
        return None
    return conf_map.get(conf_str.lower().strip())


def map_timeframe_key(tf_str: str) -> int | None:
    tf_map = {"3m": 1, "6-12m": 2, "12-24m": 3}
    if not tf_str:
        return None
    return tf_map.get(tf_str.lower().strip())


def map_style_key(style_str: str) -> int | None:
    style_map = {"momentum": 1, "value": 2, "sentiment": 3, "quality": 5, "low_vol": 7}
    if not style_str:
        return None
    return style_map.get(style_str.lower().strip())


def build_request_params(model_choice: str, settings: Settings) -> RequestParams:
    """Build RequestParams for mcp-agent with the selected model.

    Notes:
    - mcp-agent's `RequestParams` uses camelCase fields (e.g., `maxTokens`).
    - The OpenAI adapter maps `maxTokens` to `max_completion_tokens` for reasoning
      models (o1/o3/o4/gpt-5) and to `max_tokens` for others.
    - We always set `model` explicitly so the planner and workers don't fallback
      to a provider-selected default (which can be `o3`).
    """

    # Decide an optional token limit in the unified `maxTokens` field.
    max_tokens_unified: int | None = None
    if model_choice.lower().startswith("gpt-5"):
        if settings.openai_max_completion_tokens is not None:
            max_tokens_unified = int(settings.openai_max_completion_tokens)
    else:
        if settings.openai_max_tokens is not None:
            max_tokens_unified = int(settings.openai_max_tokens)

    if max_tokens_unified is not None:
        return RequestParams(model=model_choice, maxTokens=max_tokens_unified)
    else:
        # At minimum, set the model so selection never falls back to o3.
        return RequestParams(model=model_choice)


async def _monitor_report_and_cancel(
    *,
    output_path: str,
    timeout_seconds: int,
    orchestrator_task: asyncio.Task,
    logger: logging.Logger,
) -> bool:
    """Watch for a valid fenced-JSON report, then cancel the orchestrator.

    Returns True if a valid report was detected within the timeout; False otherwise.
    """
    start = time.monotonic()
    last_error: str | None = None
    while (time.monotonic() - start) < max(1, int(timeout_seconds)):
        if orchestrator_task.done():
            return False
        try:
            if os.path.exists(output_path) and os.path.isfile(output_path):
                try:
                    if os.path.getsize(output_path) < 1000:
                        await asyncio.sleep(0.5)
                        continue
                except Exception:
                    pass
                try:
                    with open(output_path, "r", encoding="utf-8") as f:
                        raw = f.read()
                    json_str = extract_json_block(raw)
                    _ = json.loads(json_str)
                    logger.info(
                        f"Detected valid report at {output_path}; cancelling orchestrator early"
                    )
                    with contextlib.suppress(Exception):
                        orchestrator_task.cancel()
                    return True
                except Exception as e:
                    last_error = str(e)
        except Exception:
            pass
        await asyncio.sleep(0.5)
    if last_error:
        logger.debug(f"Report monitor timed out; last validation error: {last_error}")
    return False

def load_json_and_insert(report_path):
    # Read and parse
    settings = Settings()
    logger = get_logger(__name__)
    logger.info(f"Loading report JSON into database from {report_path}")
    with open(report_path, 'r') as f:
        raw = f.read()
    json_str = extract_json_block(raw)
    data = json.loads(json_str)
    try:
        logger.info(
            f"Parsed report: ticker={data.get('ticker')}, company={data.get('company_name')}, date={data.get('as_of_date')}"
        )
    except Exception:
        pass

    conn = psycopg2.connect(
        database=settings.database_name,
        user=settings.db_username,
        password=settings.password,
        host=settings.host,
        port=settings.port,
    )
    cur = conn.cursor()
    try:
        insert_main = (
            "INSERT INTO rankalpha.fact_ai_stock_analysis"
            "(date_key, stock_key, source_key, market_cap_usd, revenue_cagr_3y_pct,"
            " gross_margin_trend_key, net_margin_trend_key, free_cash_flow_trend_key,"
            " insider_activity_key, beta_sp500, rate_sensitivity_bps, fx_sensitivity,"
            " commodity_exposure, news_sentiment_30d, social_sentiment_7d, options_skew_30d,"
            " short_interest_pct_float, employee_glassdoor_score, headline_buzz_score, commentary,"
            " overall_rating_key, confidence_key, timeframe_key)"
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            " RETURNING analysis_id"
        )
        # Ensure source exists (create if missing) and use its key
        source_key_val = get_or_create_source_key(cur, SENTIMENT_SOURCE_NAME, "1")
        main_vals = (
            int(data['as_of_date'].replace('-', '')),
            get_stock_key(cur, data['ticker']),
            source_key_val,
            data.get('market_cap_usd'),
            data['fundamental'].get('revenue_cagr_3y_pct'),
            map_trend_key(data['fundamental'].get('gross_margin_trend')),
            map_trend_key(data['fundamental'].get('net_margin_trend')),
            map_trend_key(data['fundamental'].get('free_cash_flow_trend')),
            map_trend_key(data['fundamental'].get('insider_activity')),
            data['macro_sensitivity'].get('beta_sp500'),
            data['macro_sensitivity'].get('rate_sensitivity_bps'),
            map_confidence_key(data['macro_sensitivity'].get('fx_sensitivity')),
            map_confidence_key(data['macro_sensitivity'].get('commodity_exposure')),
            data['sentiment'].get('news_sentiment_30d'),
            data['sentiment'].get('social_sentiment_7d'),
            data['sentiment'].get('options_skew_30d'),
            data['sentiment'].get('short_interest_pct_float'),
            data['sentiment'].get('employee_glassdoor_score'),
            data['sentiment'].get('headline_buzz_score'),
            data['sentiment'].get('commentary'),
            map_rating_key(data.get('overall_rating')),
            map_confidence_key(data.get('confidence')),
            map_timeframe_key(data.get('recommendation_timeframe'))
        )
        cur.execute(insert_main, main_vals)
        row = cur.fetchone()
        if row is None:
            raise ValueError("No analysis_id returned from INSERT")
        analysis_id = row[0]
        try:
            logger.info(
                f"Inserted analysis_id={analysis_id} for {data.get('company_name')} ({data.get('ticker')}) on {data.get('as_of_date')}"
            )
        except Exception:
            logger.info(f"Inserted analysis_id={analysis_id}")

        # Valuation metrics
        val = data['fundamental'].get('valuation_vs_peers', {})
        cur.execute(
            "INSERT INTO rankalpha.fact_ai_valuation_metrics"
            "(analysis_id, pe_forward, ev_ebitda_forward, pe_percentile_in_sector)"
            "VALUES (%s, %s, %s, %s)",
            (analysis_id, val.get('pe_forward'), val.get('ev_ebitda_forward'), val.get('pe_percentile_in_sector'))
        )

        # Peer comparisons
        peer_values = []
        for p in data.get('peer_analysis', []):
            peer_key = get_stock_key(cur, p['ticker'])
            if peer_key:
                peer_values.append((
                    analysis_id,
                    peer_key,
                    p.get('pe_forward'),
                    p.get('ev_ebitda_forward'),
                    p.get('1y_price_total_return_pct'),
                    p.get('summary')
                ))
        if peer_values:
            execute_values(
                cur,
                "INSERT INTO rankalpha.fact_ai_peer_comparison"
                "(analysis_id, peer_stock_key, pe_forward, ev_ebitda_forward, return_1y_pct, summary) VALUES %s",
                peer_values
            )

        # Factor scores
        fs = data.get('factor_scores', {})
        fs_vals = [
            (analysis_id, map_style_key(k), v)
            for k, v in fs.items()
            if map_style_key(k) is not None
        ]
        if fs_vals:
            execute_values(
                cur,
                "INSERT INTO rankalpha.fact_ai_factor_score"
                "(analysis_id, style_key, score) VALUES %s",
                fs_vals
            )

        # Catalysts
        for ct in data.get('catalysts', {}).get('shortTerm', []):
            # Accept either probability_pct or probability_ptc from the JSON
            prob = ct.get('probability_pct')
            if prob is None:
                prob = ct.get('probability_ptc')
            # Accept either price_drop_risk_pct or price_drop_ptc_risk_if_fails
            drop_risk = ct.get('price_drop_risk_pct')
            if drop_risk is None:
                drop_risk = ct.get('price_drop_ptc_risk_if_fails')
            cur.execute(
                "INSERT INTO rankalpha.fact_ai_catalyst"
                "(analysis_id, catalyst_type, title, description, probability_pct, expected_price_move_pct, expected_date, priced_in_pct, price_drop_risk_pct)"
                "VALUES (%s, 'short', %s, %s, %s, %s, %s, %s, %s)",
                (
                    analysis_id,
                    ct.get('title'),
                    ct.get('description'),
                    prob,
                    ct.get('expected_price_move_pct'),
                    ct.get('expected_date'),
                    ct.get('priced_in_pct'),
                    drop_risk,
                )
            )
        for ct in data.get('catalysts', {}).get('longTerm', []):
            prob = ct.get('probability_pct')
            if prob is None:
                prob = ct.get('probability_ptc')
            drop_risk = ct.get('price_drop_risk_pct')
            if drop_risk is None:
                drop_risk = ct.get('price_drop_ptc_risk_if_fails')
            cur.execute(
                "INSERT INTO rankalpha.fact_ai_catalyst"
                "(analysis_id, catalyst_type, title, description, probability_pct, expected_price_move_pct, expected_date, priced_in_pct, price_drop_risk_pct)"
                "VALUES (%s, 'long', %s, %s, %s, %s, %s, %s, %s)",
                (
                    analysis_id,
                    ct.get('title'),
                    ct.get('description'),
                    prob,
                    ct.get('expected_price_move_pct'),
                    ct.get('expected_date'),
                    ct.get('priced_in_pct'),
                    drop_risk,
                )
            )

        # Price scenarios
        for stype, scenario in data.get('scenario_price_targets', {}).items():
            scen_prob = scenario.get('probability_pct')
            if scen_prob is None:
                scen_prob = scenario.get('probability_ptc')
            cur.execute(
                "INSERT INTO rankalpha.fact_ai_price_scenario"
                "(analysis_id, scenario_type, price_target, probability_pct) VALUES (%s, %s, %s, %s)",
                (analysis_id, stype, scenario.get('price'), scen_prob)
            )

        # Headline risks & data gaps
        for risk in data.get('analyst_summary', {}).get('headline_risks', []):
            cur.execute(
                "INSERT INTO rankalpha.fact_ai_headline_risk (analysis_id, risk_text) VALUES (%s, %s)",
                (analysis_id, risk)
            )
        for gap in data.get('data_gaps', []):
            cur.execute(
                "INSERT INTO rankalpha.fact_ai_data_gap (analysis_id, gap_text) VALUES (%s, %s)",
                (analysis_id, gap)
            )

        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()


async def ai_analysis(company_name, analyzer_app, symbol: str | None = None):
    os.makedirs(OUTPUT_DIR, exist_ok=True, mode=0o777)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"{company_name.lower().replace(' ', '_')}_report_{timestamp}.md"
    output_path = os.path.join(OUTPUT_DIR, output_file)
    logger = get_logger(__name__)
    logger.info(f"Preparing analysis for {company_name} → output: {output_path}")

    # Use the shared analyzer_app instance passed from the main function
    try:
        context = analyzer_app.context
        # Load settings to source env-backed values
        settings = Settings()
        openai_key = settings.openai_api_key
        if openai_key:
            try:
                # Preserve existing OpenAI config (e.g., default_model) and just set api_key
                if isinstance(context.config.openai, dict):
                    context.config.openai["api_key"] = openai_key
                else:
                    setattr(context.config.openai, "api_key", openai_key)
            except Exception:
                # Fallback to dict if structure isn't present
                context.config.openai = {"api_key": openai_key}
        else:
            logger.warning("OPENAI_API_KEY not found in environment.")

        # Ensure model override from environment is reflected in the MCP context config
        env_model = settings.openai_model
        try:
            current_default = (
                context.config.openai.get("default_model")
                if isinstance(context.config.openai, dict)
                else getattr(context.config.openai, "default_model", None)
            )
        except Exception:
            current_default = None

        if env_model and env_model != current_default:
            try:
                if isinstance(context.config.openai, dict):
                    context.config.openai["default_model"] = env_model
                else:
                    setattr(context.config.openai, "default_model", env_model)
                logger.info(f"Overriding config default model to '{env_model}' from OPENAI_MODEL")
            except Exception as e:
                logger.warning(f"Could not set default model in context: {e}")
        
        # Optionally disable or override reasoning effort to avoid fallback to o3
        disable_reasoning = bool(settings.openai_disable_reasoning)
        override_effort = settings.openai_reasoning_effort  # low | medium | high
        try:
            if disable_reasoning:
                # Remove the reasoning_effort field entirely to avoid client fallback to reasoning models
                if isinstance(context.config.openai, dict):
                    context.config.openai.pop("reasoning_effort", None)
                else:
                    try:
                        delattr(context.config.openai, "reasoning_effort")
                    except Exception:
                        pass
                logger.info("Reasoning disabled via OPENAI_DISABLE_REASONING=1 (removed reasoning_effort from config)")
            elif override_effort:
                if override_effort not in {"low", "medium", "high"}:
                    logger.warning(f"Ignoring invalid OPENAI_REASONING_EFFORT='{override_effort}'. Use low|medium|high.")
                else:
                    if isinstance(context.config.openai, dict):
                        context.config.openai["reasoning_effort"] = override_effort
                    else:
                        setattr(context.config.openai, "reasoning_effort", override_effort)
                    logger.info(f"Reasoning effort set to '{override_effort}' via OPENAI_REASONING_EFFORT")
        except Exception as e:
            logger.warning(f"Could not adjust reasoning settings: {e}")
        # Log the effective default after any override
        try:
            effective_default = (
                context.config.openai.get("default_model")
                if isinstance(context.config.openai, dict)
                else getattr(context.config.openai, "default_model", None)
            )
            logger.info(f"Effective default model in context: '{effective_default}'")
            try:
                effective_effort = (
                    context.config.openai.get("reasoning_effort")
                    if isinstance(context.config.openai, dict)
                    else getattr(context.config.openai, "reasoning_effort", None)
                )
                logger.info(f"Effective reasoning_effort in context: '{effective_effort}'")
            except Exception:
                pass
        except Exception:
            pass

        if "filesystem" in context.config.mcp.servers:
            # Ensure the filesystem server has access to the OUTPUT_DIR
            context.config.mcp.servers["filesystem"].args.extend([OUTPUT_DIR, os.getcwd()])
            logger.info(f"Filesystem server configured with access to {OUTPUT_DIR}")
        else:
            logger.warning("Filesystem server not configured - report saving may fail")

        if "g-search" not in context.config.mcp.servers:
            logger.warning(
                "Google Search server not found! This script requires g-search-mcp"
            )
            logger.info("You can install it with: npm install -g g-search-mcp")
            return False
        
        for srv in ("g-search", "fetch", "yfinance", "edgar"):
            if srv not in context.config.mcp.servers:
                # Create a minimal server entry so MCP can route to it
                context.config.mcp.servers[srv] = SimpleNamespace(args=[])
                logger.info(f"Registered missing MCP server '{srv}'")

        research_agent = Agent(
            name="search_finder",
            instruction=load_prompt("search_finder", {"COMPANY_NAME": company_name}),
            server_names=["g-search", "fetch", "yfinance", "edgar"],
        )

        # Research evaluator: Evaluates the quality of research
        research_evaluator = Agent(
            name="research_evaluator",
            instruction=load_prompt("research_evaluator", {"COMPANY_NAME": company_name}),
        )

        # Resolve model preference early: ENV overrides config
        configured_model = None
        try:
            if isinstance(context.config.openai, dict):
                configured_model = context.config.openai.get("default_model")
            else:
                configured_model = getattr(context.config.openai, "default_model", None)
        except Exception:
            configured_model = None

        model_choice = settings.openai_model or configured_model
        if not model_choice:
            logger.error(
                "No OpenAI model configured. Set OPENAI_MODEL or openai.default_model in apps/sentiment/src/mcp_agent.config.yaml"
            )
            return False

        # Custom factory to ensure 'gpt-5*' is treated as reasoning in older mcp-agent versions
        def llm_factory(agent: Agent) -> OpenAIAugmentedLLM:
            # For GPT‑5 family, prefer a hybrid approach: use a stable planner model while keeping GPT‑5 for workers
            is_gpt5 = str(model_choice).lower().startswith("gpt-5")
            name_val = (getattr(agent, "name", "") or "")
            is_planner = bool(agent and (name_val == "LLM Orchestration Planner" or "planner" in name_val.lower()))

            # Strengthen planner instruction regardless of model to avoid human-ask tasks
            if agent and is_planner:
                planner_instruction = (
                    """
                    You are an expert planner. Given an objective task and a list of available Agents and MCP servers,
                    break the objective into strictly actionable steps and parallelizable subtasks. Never ask the user
                    for input and never include tasks that request human guidance. Only use the provided Agents and their
                    servers to accomplish the goal. Do not restate or copy any agent's instruction text (e.g., data
                    collection checklists or rating criteria) into task descriptions; keep tasks concise and refer only
                    to the agent names.

                    PLANNING RULES:
                    - Always produce exactly three steps in this order: (1) research_quality_controller, (2) financial_analyst, (3) report_writer.
                    - In your first plan output, set is_complete=false so the orchestrator executes these steps.
                    - On subsequent planning iterations, inspect the provided plan_result and step_results. If all three steps have already been executed and the report_writer step returned a confirmation line that begins with 'SAVED:', then return steps=[] and set is_complete=true. Do not repeat previously executed steps.
                    - Do not add any extra steps, loops, or ask for human input.

                    Produce valid JSON as specified by the schema without any extra text.
                    """
                )
                agent = Agent(name=agent.name, instruction=planner_instruction)

            if is_gpt5:
                # Use Responses API with tool bridging for all GPT‑5 agents (planner and workers)
                chosen_model = settings.openai_planner_model if is_planner and settings.openai_planner_model else model_choice
                llm = Gpt5ResponsesPlannerLLM(agent=agent)
                if llm.default_request_params:
                    llm.default_request_params.model = chosen_model
                else:
                    llm.default_request_params = RequestParams(model=chosen_model)
                try:
                    logging.getLogger(__name__).info(
                        f"LLM selection: agent={getattr(agent, 'name', 'unknown')} model={chosen_model} wrapper=Gpt5ResponsesPlannerLLM"
                    )
                except Exception:
                    pass
            else:
                llm = OpenAIAugmentedLLM(agent=agent)
                try:
                    logging.getLogger(__name__).info(
                        f"LLM selection: agent={getattr(agent, 'name', 'unknown')} model={model_choice} wrapper=OpenAIAugmentedLLM"
                    )
                except Exception:
                    pass
            # Force recognition of gpt-5* as reasoning models if the installed mcp-agent is older
            try:
                llm._reasoning = lambda m: bool(
                    m and (str(m).startswith(("o1", "o3", "o4")) or str(m).lower().startswith("gpt-5"))
                )
            except Exception:
                pass
            # Ensure default model matches the env/config so components that don't get explicit
            # RequestParams still use the correct model
            try:
                if llm.default_request_params:
                    llm.default_request_params.model = model_choice
                    # For GPT‑5, avoid sending systemPrompt entirely; we use a developer message instead
                    if is_gpt5 and hasattr(llm.default_request_params, "systemPrompt"):
                        llm.default_request_params.systemPrompt = None  # type: ignore[attr-defined]
                else:
                    llm.default_request_params = RequestParams(model=model_choice)
            except Exception:
                pass
            return llm

        # Create the research EvaluatorOptimizerLLM component (no duplicate criteria in user prompts)
        research_quality_controller = EvaluatorOptimizerLLMNoDup(
            optimizer=research_agent,
            evaluator=research_evaluator,
            llm_factory=llm_factory,
            min_rating=QualityRating.EXCELLENT,
        )
        # Ensure a stable, schema-friendly name (no hyphens) for planner validation
        try:
            setattr(research_quality_controller, "name", "research_quality_controller")
        except Exception:
            pass

        # Analyst agent: Analyzes the research data
        analyst_agent = Agent(
            name="financial_analyst",
            instruction=load_prompt("financial_analyst", {"COMPANY_NAME": company_name}),
            # Include filesystem to allow direct save in fallback flows if the model chooses
            server_names=["fetch", "yfinance", "edgar", "filesystem"],
        )

        # Report writer: Creates the final report
        report_writer = Agent(
            name="report_writer",
            instruction=load_prompt("report_writer", {"COMPANY_NAME": company_name, "OUTPUT_PATH": output_path}),
            server_names=["filesystem"],
        )

        # --- CREATE THE ORCHESTRATOR ---
        logger.info(f"Initializing stock analysis workflow for {company_name}")

        orchestrator = Orchestrator(
            llm_factory=llm_factory,
            available_agents=[
                research_quality_controller,
                analyst_agent,
                report_writer,
            ],
            plan_type="full",
        )

        # Define the task for the orchestrator
        task = load_prompt(
            "orchestrator_task",
            {"COMPANY_NAME": company_name, "OUTPUT_PATH": output_path},
        )
        source = "env" if settings.openai_model else "config"
        logger.info(f"Using LLM model '{model_choice}' (source: {source})")
        if symbol:
            logger.info(f"Processing symbol {symbol} using model '{model_choice}'")
        else:
            logger.info(f"Processing company {company_name} using model '{model_choice}'")

        # Run the orchestrator
        logger.info(f"Starting analysis workflow for {company_name}")

        # Build request params with correct token field based on model
        req_params = build_request_params(model_choice, settings)
        # Add a small debug log of token field if set
        token_field = (
            "max_completion_tokens" if model_choice.lower().startswith("gpt-5") else "max_tokens"
        )
        token_val = (
            settings.openai_max_completion_tokens
            if model_choice.lower().startswith("gpt-5")
            else settings.openai_max_tokens
        )
        if token_val is not None:
            logger.info(f"Token limit: {token_field}={token_val}")

        orchestrator_timeout = int(getattr(settings, "sentiment_orchestrator_timeout_seconds", 600))
        orc_text: str | None = None
        # Run orchestrator + monitor concurrently, allowing early stop when the report is saved
        orch_task = asyncio.create_task(
            orchestrator.generate_str(message=task, request_params=req_params)
        )
        monitor_task = asyncio.create_task(
            _monitor_report_and_cancel(
                output_path=output_path,
                timeout_seconds=orchestrator_timeout,
                orchestrator_task=orch_task,
                logger=logger,
            )
        )
        try:
            orc_text = await asyncio.wait_for(orch_task, timeout=orchestrator_timeout)
        except asyncio.CancelledError:
            # Likely cancelled by the monitor after a valid report write
            try:
                if not monitor_task.done():
                    await monitor_task
            except Exception:
                pass
            orc_text = None
        except asyncio.TimeoutError:
            # Do not retry here; propagate timeout so callers can decide policy
            logger.warning(
                f"Orchestrator timed out after {orchestrator_timeout}s; aborting analysis without retry."
            )
            with contextlib.suppress(Exception):
                monitor_task.cancel()
            raise
        finally:
            # Ensure the monitor task is cleaned up
            if not monitor_task.done():
                with contextlib.suppress(Exception):
                    monitor_task.cancel()
                    await monitor_task

        # Check if report was successfully created
        # Best-effort fallback: only write if the orchestrator returned a valid fenced JSON block
        if (not os.path.exists(output_path)) and isinstance(orc_text, str) and orc_text.strip():
            try:
                _ = extract_json_block(orc_text)
                with open(output_path, "w", encoding="utf-8") as f:
                    f.write(orc_text)
                logger.info(f"Report created via fallback write from fenced JSON: {output_path}")
            except Exception:
                # No valid JSON block -> skip fallback to avoid empty files
                pass

        if os.path.exists(output_path):
            logger.info(f"Report successfully generated: {output_path}")
            load_json_and_insert(output_path)
            # Log tool usage summary (GPT‑5 Responses wrapper aggregates counts per process)
            try:
                Gpt5ResponsesPlannerLLM.log_tool_usage_summary(logger=logger, reset=False)
            except Exception:
                pass
            logger.info("Finished analysis")
            return True
        else:
            logger.error(f"Failed to create report at {output_path}")
            # Emit tool-usage summary even on failure for observability
            try:
                Gpt5ResponsesPlannerLLM.log_tool_usage_summary(logger=logger, reset=False)
            except Exception:
                pass
            logger.info("Not retrying this analysis attempt")
            return False

    except asyncio.TimeoutError:
        # Propagate to caller; upstream will avoid retrying on timeouts
        raise
    except Exception as e:
        logger.error(f"Error during workflow execution: {str(e)}")
        logger.info("Not retrying this analysis attempt")
        return False

def load_schedule():
    """Load the analysis schedule from JSON file."""
    if SCHEDULE_FILE.exists():
        try:
            with open(SCHEDULE_FILE, 'r') as f:
                data = json.load(f)
                # Convert date strings back to date objects
                for stock_key in data:
                    data[stock_key]['analysis_dates'] = [
                        datetime.strptime(date_str, '%Y-%m-%d').date() 
                        for date_str in data[stock_key]['analysis_dates']
                    ]
                return data
        except Exception as e:
            logger = get_logger(__name__)
            logger.error(f"Error loading schedule: {e}")
            return {}
    return {}

def save_schedule(schedule):
    """Save the analysis schedule to JSON file, ensuring no duplicate dates per stock."""
    try:
        # Convert date objects to strings for JSON serialization
        data = {}
        for stock_key, info in schedule.items():
            # Ensure analysis_dates are unique by converting to set and back
            unique_dates = list(set(info['analysis_dates']))
            unique_dates.sort()
            
            data[stock_key] = {
                'company_name': info['company_name'],
                'symbol': info['symbol'],
                'analysis_dates': [
                    date.strftime('%Y-%m-%d') if hasattr(date, 'strftime') else date
                    for date in unique_dates
                ]
            }
        
        os.makedirs(SCHEDULE_FILE.parent, exist_ok=True)
        with open(SCHEDULE_FILE, 'w') as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        logger = get_logger(__name__)
        logger.error(f"Error saving schedule: {e}")

def clean_schedule():
    """Clean the schedule to ensure no duplicate dates per stock."""
    logger = get_logger(__name__)
    schedule = load_schedule()
    
    cleaned = False
    for stock_key, info in schedule.items():
        original_count = len(info['analysis_dates'])
        # Remove duplicates while preserving order
        unique_dates = []
        seen = set()
        for date in info['analysis_dates']:
            if date not in seen:
                unique_dates.append(date)
                seen.add(date)
        
        info['analysis_dates'] = unique_dates
        
        if original_count != len(unique_dates):
            logger.info(f"Cleaned schedule for {info['symbol']}: removed {original_count - len(unique_dates)} duplicate dates")
            cleaned = True
    
    if cleaned:
        save_schedule(schedule)
        logger.info("Schedule cleaned and saved")
    
    return schedule

def remove_date_from_schedule(stock_key_str: str, date_obj: datetime.date) -> None:
    """Remove a specific date from the schedule for a stock, if present."""
    try:
        schedule = load_schedule()
        if stock_key_str in schedule:
            before = len(schedule[stock_key_str]['analysis_dates'])
            schedule[stock_key_str]['analysis_dates'] = [d for d in schedule[stock_key_str]['analysis_dates'] if d != date_obj]
            after = len(schedule[stock_key_str]['analysis_dates'])
            if after != before:
                save_schedule(schedule)
    except Exception:
        pass

def update_schedule_with_catalysts(stock_key, company_name, symbol, analysis_id, cursor):
    """Update the schedule with new analysis dates based on catalyst expected dates.
    Ensures only one analysis per stock per day."""
    logger = get_logger(__name__)
    schedule = load_schedule()
    
    # Initialize stock entry if not exists
    if stock_key not in schedule:
        schedule[stock_key] = {
            'company_name': company_name,
            'symbol': symbol,
            'analysis_dates': []
        }
    
    # Get catalyst dates from the latest analysis
    cursor.execute("""
        SELECT expected_date 
        FROM fact_ai_catalyst 
        WHERE analysis_id = %s AND expected_date IS NOT NULL
    """, (analysis_id,))
    
    catalyst_dates = cursor.fetchall()
    new_dates = set()
    
    for (expected_date,) in catalyst_dates:
        if expected_date:
            # Add analysis dates: 7 days before, 1 day after, 7 days after
            # Using a set automatically prevents duplicate dates
            new_dates.add(expected_date - timedelta(days=7))  # 7 days before
            new_dates.add(expected_date + timedelta(days=1))   # 1 day after
            new_dates.add(expected_date + timedelta(days=7))   # 7 days after
    
    # Merge with existing dates and remove past dates
    current_date = datetime.now().date()
    existing_dates = set(schedule[stock_key]['analysis_dates'])
    all_dates = existing_dates.union(new_dates)
    
    # Keep only future dates (set ensures no duplicates)
    future_dates = [date for date in all_dates if date >= current_date]
    future_dates.sort()
    
    # Log if we're consolidating multiple analyses into one
    if len(new_dates) > len(set(new_dates)):
        logger.info(f"Consolidated multiple catalyst-triggered analyses for {company_name} ({symbol}) to ensure max 1 per day")
    
    schedule[stock_key]['analysis_dates'] = future_dates
    logger.info(
        f"Updated schedule for {company_name} ({symbol}): +{len(new_dates)} catalyst-derived dates, {len(future_dates)} future dates total"
    )
    save_schedule(schedule)
    
    return schedule

async def check_stock_analyses(analyzer_app):
    settings = Settings()
    logger = get_logger(__name__)

    def get_db_connection():
        """Get a fresh database connection with retry logic."""
        max_retries = 3
        for attempt in range(max_retries):
            try:
                return psycopg2.connect(
                    database=settings.database_name,
                    user=settings.db_username,
                    password=settings.password,
                    host=settings.host,
                    port=settings.port,
                    connect_timeout=30  # 30 second timeout
                )
            except psycopg2.OperationalError as e:
                if attempt == max_retries - 1:
                    logger.error(f"Failed to connect to database after {max_retries} attempts: {e}")
                    raise
                logger.warning(f"Database connection attempt {attempt + 1} failed, retrying: {e}")
                time.sleep(2 ** attempt)  # Exponential backoff
    
    # Load existing schedule
    schedule = load_schedule()
    current_date = datetime.now().date()
    
    # Get all stocks using a fresh connection, prioritizing those without analysis
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Get stocks sorted by whether they have analysis (NULL analysis_id first)
        cur.execute("""
            SELECT ds.stock_key, ds.company_name, ds.symbol,
                   CASE WHEN fasa.stock_key IS NULL THEN 0 ELSE 1 END as has_analysis
            FROM dim_stock ds
            LEFT JOIN (
                SELECT DISTINCT stock_key 
                FROM fact_ai_stock_analysis
            ) fasa ON ds.stock_key = fasa.stock_key
            WHERE ds.is_active IS TRUE
            ORDER BY has_analysis ASC, ds.company_name ASC
        """)
        stocks_with_priority = cur.fetchall()
        # Extract just the stock info (first 3 columns)
        stocks = [(row[0], row[1], row[2]) for row in stocks_with_priority]
        
        # Log priority information
        stocks_without_analysis = sum(1 for row in stocks_with_priority if row[3] == 0)
        logger.info(f"Found {len(stocks)} total stocks, {stocks_without_analysis} without analysis (will be processed first)")
        
    finally:
        cur.close()
        conn.close()
    
    processed_count = 0
    skipped_recent = 0
    for stock_key, company_name, stock_symbol in stocks:
        try:
            stock_key_str = str(stock_key)
            # Skip if we've already completed this stock today in this process
            if _already_completed_today(stock_key):
                logger.info(f"Skipping {company_name} ({stock_symbol}): already completed today in this run")
                continue
            
            # First, ALWAYS check if this company has any analysis at all - regardless of schedule
            conn = get_db_connection()
            cur = conn.cursor()
            try:
                cur.execute("""
                    SELECT analysis_id, date_key 
                    FROM fact_ai_stock_analysis 
                    WHERE stock_key = %s
                    ORDER BY date_key DESC
                    LIMIT 1
                """, (stock_key,))
                
                existing_analysis = cur.fetchone()
            finally:
                cur.close()
                conn.close()
            
            # If no analysis exists, run immediate analysis regardless of schedule
            if not existing_analysis:
                logger.info(f"🚀 PRIORITY: No analysis found for {company_name} ({stock_symbol}) - running immediate initial analysis")
                try:
                    success = await ai_analysis(company_name, analyzer_app, stock_symbol)
                except asyncio.TimeoutError:
                    logger.warning(
                        f"Initial analysis timed out for {company_name} ({stock_symbol}); skipping retries for this run"
                    )
                    success = False

                if success:
                    # Get the newly created analysis ID using fresh connection
                    conn = get_db_connection()
                    cur = conn.cursor()
                    try:
                        cur.execute("""
                            SELECT analysis_id 
                            FROM fact_ai_stock_analysis 
                            WHERE stock_key = %s
                            ORDER BY date_key DESC
                            LIMIT 1
                        """, (stock_key,))
                        
                        new_analysis = cur.fetchone()
                        if new_analysis:
                            update_schedule_with_catalysts(stock_key_str, company_name, stock_symbol, 
                                                          new_analysis[0], cur)
                            _mark_completed_today(stock_key)
                    finally:
                        cur.close()
                        conn.close()
                continue  # Move to next stock since we just did the analysis
            
            # Analysis exists - now check scheduling logic
            if stock_key_str not in schedule:
                # Analysis exists but no schedule, create schedule from existing catalysts
                analysis_id = existing_analysis[0]
                conn = get_db_connection()
                cur = conn.cursor()
                try:
                    update_schedule_with_catalysts(stock_key_str, company_name, stock_symbol, 
                                                  analysis_id, cur)
                    logger.info(f"Initialized schedule from catalysts for {company_name} ({stock_symbol})")
                finally:
                    cur.close()
                    conn.close()
            else:
                # Check if today is a scheduled analysis date
                scheduled_dates = schedule[stock_key_str]['analysis_dates']
                
                if current_date in scheduled_dates and not _already_completed_today(stock_key):
                    logger.info(f"Running scheduled analysis for {company_name} ({stock_symbol}) on {current_date}")
                    # DB guard: skip if last analysis within N-day window
                    try:
                        skip_window = int(getattr(Settings(), "sentiment_skip_if_within_days", 1) or 1)
                    except Exception:
                        skip_window = 1
                    try:
                        conn2 = get_db_connection()
                        cur2 = conn2.cursor()
                        try:
                            cur2.execute(
                                "SELECT MAX(date_key) FROM fact_ai_stock_analysis WHERE stock_key = %s",
                                (stock_key,),
                            )
                            last_date_key = cur2.fetchone()[0]
                        finally:
                            cur2.close()
                            conn2.close()
                        if last_date_key:
                            last_date = datetime.strptime(str(last_date_key), "%Y%m%d").date()
                            delta_days = (current_date - last_date).days
                            if delta_days >= 0 and delta_days < max(skip_window, 1):
                                logger.info(
                                    f"Skipping scheduled analysis for {company_name} ({stock_symbol}): last run {delta_days} days ago (< {max(skip_window,1)}d)"
                                )
                                remove_date_from_schedule(stock_key_str, current_date)
                                skipped_recent += 1
                                continue
                    except Exception:
                        pass
                    try:
                        success = await ai_analysis(company_name, analyzer_app, stock_symbol)
                    except asyncio.TimeoutError:
                        logger.warning(
                            f"Scheduled analysis timed out for {company_name} ({stock_symbol}); skipping retries for this run"
                        )
                        success = False

                    if success:
                        # Get the newly created analysis ID using fresh connection
                        conn = get_db_connection()
                        cur = conn.cursor()
                        try:
                            cur.execute("""
                                SELECT analysis_id 
                                FROM fact_ai_stock_analysis 
                                WHERE stock_key = %s
                                ORDER BY date_key DESC
                                LIMIT 1
                            """, (stock_key,))
                            
                            new_analysis = cur.fetchone()
                            if new_analysis:
                                # Update schedule with new catalyst dates
                                update_schedule_with_catalysts(stock_key_str, company_name, stock_symbol, 
                                                              new_analysis[0], cur)
                        finally:
                            cur.close()
                            conn.close()
                                
                        # Remove today's date from schedule since we've completed it
                        remove_date_from_schedule(stock_key_str, current_date)
                        _mark_completed_today(stock_key)
                        processed_count += 1
        except Exception as e:
            logger.error(f"Error processing stock {company_name} ({stock_symbol}): {e}")
            # Continue with next stock instead of failing the entire process
    try:
        logger.info(
            f"Scheduled check summary: processed={processed_count}, skipped_recent={skipped_recent}, total_stocks={len(stocks)}"
        )
    except Exception:
        pass


async def async_main(symbol: str | None = None, force: bool = False):
    logger = get_logger(__name__)

    # Load settings and configure data paths based on env files
    settings = Settings()
    # Set global paths so downstream helpers use correct locations
    global OUTPUT_DIR, SCHEDULE_FILE
    data_dir = settings.sentiment_data_dir or "/data"
    OUTPUT_DIR = settings.sentiment_output_dir or os.path.join(data_dir, "company_reports")
    SCHEDULE_FILE = Path(
        settings.sentiment_schedule_file
        or os.path.join(data_dir, "analysis_schedule", "analysis_schedule.json")
    )

    # Ensure primary data directories exist before any server startup
    try:
        os.makedirs(OUTPUT_DIR, exist_ok=True, mode=0o777)
    except Exception as e:
        logger.warning(f"Could not create OUTPUT_DIR '{OUTPUT_DIR}': {e}")
    try:
        os.makedirs(SCHEDULE_FILE.parent, exist_ok=True, mode=0o777)
    except Exception as e:
        logger.warning(f"Could not create schedule dir '{SCHEDULE_FILE.parent}': {e}")

    # Configure optional file logging for OpenAI/MCP traces under DATA_DIR/logs
    try:
        logs_dir = os.path.join(data_dir, "logs")
        os.makedirs(logs_dir, exist_ok=True)
        run_ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = os.path.join(logs_dir, f"sentiment_oai_{run_ts}.log")
        # Always attach file handler in debug mode or when full prompt logging is requested
        if bool(settings.sentiment_openai_debug) or bool(settings.sentiment_log_prompts):
            add_rotating_file_handler(path=log_file, level=logging.DEBUG)
        else:
            add_rotating_file_handler(path=log_file, level=logging.INFO)
        # Expose the log file path so downstream modules (e.g., GPT‑5 wrappers)
        # can attach their own file handlers without relying on root level.
        os.environ["SENTIMENT_LOG_FILE"] = log_file
        logger.info(f"File logging enabled: {log_file}")
        # One-liner: summarize effective logging toggles and target file
        logger.info(
            f"Logging toggles -> openai_debug={bool(settings.sentiment_openai_debug)}, "
            f"log_prompts={bool(settings.sentiment_log_prompts)}, file={log_file}"
        )
    except Exception as e:
        logger.warning(f"Could not initialize file logging: {e}")

    logger.info("Starting scheduled stock analysis system...")
    logger.info(f"Schedule file location: {SCHEDULE_FILE}")
    
    # Ensure SEC_EDGAR_USER_AGENT is exported for MCP subprocesses
    try:
        if getattr(settings, "sec_edgar_user_agent", None) and not os.getenv("SEC_EDGAR_USER_AGENT"):
            os.environ["SEC_EDGAR_USER_AGENT"] = str(settings.sec_edgar_user_agent)
            logger.info("Exported SEC_EDGAR_USER_AGENT from Settings for EDGAR MCP server")
    except Exception:
        pass
    
    # Optional OpenAI SDK debug logging to inspect actual request payloads
    # Bridge Settings -> environment flags for downstream components that read os.getenv
    # (e.g., GPT-5 prompt/response logger)
    if settings.sentiment_log_prompts:
        os.environ["SENTIMENT_LOG_PROMPTS"] = "true"

    debug_openai = bool(settings.sentiment_openai_debug)
    if debug_openai:
        # Force-set environment so child clients pick it up regardless of defaults
        os.environ["OPENAI_LOG"] = "debug"
        os.environ["OPENAI_DEBUG"] = "true"
        # Ensure the root logger has a handler, then raise verbosity for SDKs
        if not logging.getLogger().handlers:
            logging.basicConfig(
                level=logging.DEBUG,
                format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
            )
        else:
            logging.getLogger().setLevel(logging.DEBUG)
        logging.getLogger("openai").setLevel(logging.DEBUG)
        logging.getLogger("httpx").setLevel(logging.DEBUG)
        logging.getLogger("mcp_agent").setLevel(logging.DEBUG)
        logger.info("OpenAI debug logging enabled (OPENAI_LOG=debug, OPENAI_DEBUG=true)")
    
    # Clean up any existing schedule to ensure no duplicates
    if SCHEDULE_FILE.exists():
        logger.info("Cleaning existing schedule to ensure no duplicate dates...")
        clean_schedule()
    
    # Create a single MCPApp instance to be reused for all analyses
    app = MCPApp(name="unified_stock_analyzer", human_input_callback=None)

    # Pre-configure MCP servers before starting the app so env vars propagate
    try:
        cfg = app.context.config
        ua = str(settings.sec_edgar_user_agent or os.getenv("SEC_EDGAR_USER_AGENT") or "").strip()
        # If EDGAR server is configured but UA is missing, disable EDGAR to avoid startup failure
        if getattr(cfg, "mcp", None) and getattr(cfg.mcp, "servers", None):
            servers = cfg.mcp.servers
            # Ensure Filesystem server has valid root directories BEFORE servers start.
            try:
                # Normalize to a mutable mapping-like
                fs = servers.get("filesystem") if isinstance(servers, dict) else getattr(servers, "filesystem", None)
                # If missing, add a minimal definition that includes allowed roots
                allowed_roots = [OUTPUT_DIR, os.getcwd()]
                # Filter to existing, absolute paths to satisfy the server
                valid_roots = []
                for p in allowed_roots:
                    try:
                        ap = os.path.abspath(p)
                        if os.path.isdir(ap):
                            valid_roots.append(ap)
                    except Exception:
                        continue
                if not valid_roots:
                    # Last resort: attempt to create OUTPUT_DIR and retry once
                    try:
                        os.makedirs(OUTPUT_DIR, exist_ok=True, mode=0o777)
                        ap = os.path.abspath(OUTPUT_DIR)
                        if os.path.isdir(ap):
                            valid_roots = [ap]
                    except Exception:
                        pass

                if fs is None:
                    # Construct a simple server config; prefer npx variant used in repo config
                    servers["filesystem"] = {  # type: ignore[index]
                        "command": "npx",
                        "args": ["-y", "@modelcontextprotocol/server-filesystem", *valid_roots],
                    }
                    logger.info(f"Filesystem server added with roots: {valid_roots}")
                else:
                    # Append args if not already present
                    try:
                        # Access args regardless of dict or namespace
                        if isinstance(fs, dict):
                            args = list(fs.get("args") or [])
                        else:
                            args = list(getattr(fs, "args", []) or [])
                        # De-duplicate while preserving order
                        for r in valid_roots:
                            if r not in args:
                                args.append(r)
                        if isinstance(fs, dict):
                            fs["args"] = args
                        else:
                            setattr(fs, "args", args)
                        logger.info(f"Filesystem server configured with access to: {valid_roots}")
                    except Exception as e:
                        logger.warning(f"Could not update filesystem server roots: {e}")
            except Exception as e:
                logger.warning(f"Filesystem server preconfiguration failed: {e}")
            if "edgar" in servers:
                if not ua:
                    try:
                        servers.pop("edgar", None)
                        logger.warning("EDGAR MCP disabled: SEC_EDGAR_USER_AGENT not set. Set it to enable EDGAR tools.")
                    except Exception:
                        pass
                else:
                    # Attach explicit env mapping so the subprocess inherits the UA
                    try:
                        srv = servers["edgar"]
                        # Support both dict-like and SimpleNamespace
                        if isinstance(srv, dict):
                            env_map = srv.get("env") or {}
                            env_map["SEC_EDGAR_USER_AGENT"] = ua
                            srv["env"] = env_map
                        else:
                            env_map = getattr(srv, "env", None) or {}
                            env_map["SEC_EDGAR_USER_AGENT"] = ua
                            setattr(srv, "env", env_map)
                        logger.info("EDGAR MCP: injected SEC_EDGAR_USER_AGENT into server env")
                    except Exception as e:
                        logger.warning(f"Could not inject EDGAR env: {e}")

                    # Workaround for MCP runtimes that don't pass 'env' through to subprocess:
                    # rewrite the server command to export the UA inline via bash -lc
                    try:
                        # Normalize accessors
                        if isinstance(srv, dict):
                            cmd = str(srv.get("command")) if srv.get("command") is not None else "uv"
                            args = list(srv.get("args") or [])
                        else:
                            cmd = str(getattr(srv, "command", "uv"))
                            args = list(getattr(srv, "args", []) or [])

                        ua_quoted = shlex.quote(ua)
                        bash_line = f"SEC_EDGAR_USER_AGENT={ua_quoted} uv --directory ext/sec-edgar-mcp run -m sec_edgar_mcp.server"
                        # Overwrite to bash -lc form
                        if isinstance(srv, dict):
                            srv["command"] = "bash"
                            srv["args"] = ["-lc", bash_line]
                        else:
                            setattr(srv, "command", "bash")
                            setattr(srv, "args", ["-lc", bash_line])
                        logger.info("EDGAR MCP: switched launch to bash -lc with inline UA export")
                    except Exception as e:
                        logger.warning(f"Could not rewrite EDGAR launch command: {e}")
    except Exception as e:
        logger.warning(f"Could not pre-configure MCP servers: {e}")
    
    async with app.run() as analyzer_app:
        # Optional: run a one-off consensus batch and optionally exit
        async def _run_consensus_once() -> None:
            try:
                await run_consensus_batch(analyzer_app)
            except Exception as e:
                logger.error(f"Consensus batch failed: {e}")

        if bool(getattr(settings, "sentiment_use_consensus", False)) and bool(getattr(settings, "sentiment_consensus_batch_only", False)):
            logger.info("Consensus batch-only mode active: running once and exiting")
            await _run_consensus_once()
            return
        # If a specific symbol is provided, run analysis immediately (optionally forcing)
        if symbol:
            logger.info(f"On-demand mode: symbol={symbol}, force={force}")
            settings = Settings()
            # In planner dry-run mode, skip all database I/O and go straight to analysis
            # no dry-run: always use database path

            def get_db_connection():
                max_retries = 3
                for attempt in range(max_retries):
                    try:
                        return psycopg2.connect(
                            database=settings.database_name,
                            user=settings.db_username,
                            password=settings.password,
                            host=settings.host,
                            port=settings.port,
                            connect_timeout=30,
                        )
                    except psycopg2.OperationalError as e:
                        if attempt == max_retries - 1:
                            logger.error(
                                f"Failed to connect to database after {max_retries} attempts: {e}"
                            )
                            raise
                        logger.warning(
                            f"Database connection attempt {attempt + 1} failed, retrying: {e}"
                        )
                        time.sleep(2 ** attempt)

            # Lookup stock by symbol
            conn = get_db_connection()
            cur = conn.cursor()
            try:
                cur.execute(
                    "SELECT stock_key, company_name FROM dim_stock WHERE symbol = %s AND is_active IS TRUE",
                    (symbol,),
                )
                row = cur.fetchone()
            finally:
                cur.close()
                conn.close()

            if not row:
                logger.error(f"Symbol not found in dim_stock: {symbol}")
                return

            stock_key, company_name = row

            # If not forced, skip if we already ran recently (within N days)
            if not force:
                conn = get_db_connection()
                cur = conn.cursor()
                try:
                    cur.execute(
                        """
                        SELECT date_key
                        FROM fact_ai_stock_analysis
                        WHERE stock_key = %s
                        ORDER BY date_key DESC
                        LIMIT 1
                        """,
                        (stock_key,),
                    )
                    last = cur.fetchone()
                finally:
                    cur.close()
                    conn.close()

                if last:
                    last_date_key = last[0]
                    if last_date_key:
                        try:
                            skip_window = int(getattr(Settings(), "sentiment_skip_if_within_days", 1) or 1)
                        except Exception:
                            skip_window = 1
                        last_dt = datetime.strptime(str(last_date_key), "%Y%m%d").date()
                        delta_days = (datetime.now().date() - last_dt).days
                        if delta_days < max(skip_window, 1):
                            logger.info(
                                f"Skipping {symbol}: last analysis {delta_days} days ago (< {skip_window}d). Use --force to override."
                            )
                            return

            # Skip if completed earlier in this process today
            if _already_completed_today(stock_key):
                logger.info(
                    f"Skipping on-demand for {company_name} ({symbol}): already completed today in this run"
                )
                return

            logger.info(
                f"Running on-demand analysis for {company_name} ({symbol}){' with --force' if force else ''}"
            )
            try:
                success = await ai_analysis(company_name, analyzer_app, symbol)
            except asyncio.TimeoutError:
                logger.warning("On-demand analysis timed out; not retrying")
                return
            if not success:
                # Retry once for on-demand runs only if previous failure was not a timeout
                try:
                    success = await ai_analysis(company_name, analyzer_app, symbol)
                except asyncio.TimeoutError:
                    logger.warning("On-demand retry timed out; aborting")
                    return

            if success:
                # Update schedule based on catalysts from the latest analysis
                conn = get_db_connection()
                cur = conn.cursor()
                try:
                    cur.execute(
                        """
                        SELECT analysis_id
                        FROM fact_ai_stock_analysis
                        WHERE stock_key = %s
                        ORDER BY date_key DESC
                        LIMIT 1
                        """,
                        (stock_key,),
                    )
                    new_analysis = cur.fetchone()
                    if new_analysis:
                        update_schedule_with_catalysts(
                            str(stock_key), company_name, symbol, new_analysis[0], cur
                        )
                finally:
                    cur.close()
                    conn.close()
                _mark_completed_today(stock_key)
            return

        # Optionally run consensus batch before scheduled checks
        if bool(getattr(settings, "sentiment_use_consensus", False)) and int(getattr(settings, "sentiment_consensus_limit", 0) or 0) > 0:
            logger.info("Running consensus batch before scheduled checks")
            await _run_consensus_once()

        # Run initial check
        await check_stock_analyses(analyzer_app)

        # Run daily checks
        while True:
            await asyncio.sleep(86400)  # Sleep for 24 hours
            
            logger.info(f"Running daily check at {datetime.now()}")
            try:
                if bool(getattr(settings, "sentiment_use_consensus", False)) and int(getattr(settings, "sentiment_consensus_limit", 0) or 0) > 0:
                    logger.info("Running daily consensus batch")
                    await _run_consensus_once()
                # Clean schedule periodically to ensure consistency
                clean_schedule()
                await check_stock_analyses(analyzer_app)
            except Exception as e:
                logger.error(f"Error in daily check: {e}")

def main():
    parser = argparse.ArgumentParser(description="RankAlpha Sentiment Analyzer")
    parser.add_argument(
        "--symbol",
        help="Stock symbol to analyze immediately (bypasses schedule)",
        type=str,
    )
    parser.add_argument(
        "--force",
        help="Force reanalysis even if already run today",
        action="store_true",
        default=False,
    )
    args = parser.parse_args()
    # Use Settings to source defaults from env files
    try:
        settings = Settings()
    except Exception:
        settings = None
    # Allow environment variables for docker-compose usage via Settings
    if settings:
        if not args.symbol and settings.sentiment_symbol:
            args.symbol = settings.sentiment_symbol
        if not args.force and isinstance(settings.sentiment_force, bool):
            args.force = settings.sentiment_force
        # If single-symbol-only is enabled, enforce symbol-only execution and exit after
        if settings.sentiment_single_symbol_only:
            if not args.symbol:
                logger = get_logger(__name__)
                logger.error(
                    "SENTIMENT_SINGLE_SYMBOL_ONLY=1 set but no SENTIMENT_SYMBOL provided"
                )
                return
            else:
                logger = get_logger(__name__)
                logger.info(
                    f"Single-symbol mode active: symbol={args.symbol} (SENTIMENT_SINGLE_SYMBOL_ONLY=1)"
                )
    # Normalize symbol to uppercase if provided
    if args.symbol:
        args.symbol = args.symbol.upper()
    # Log startup configuration for visibility in Docker logs
    logger = get_logger(__name__)
    model_log = settings.openai_model if settings and settings.openai_model else "(config default)"
    planner_model_log = (
        settings.openai_planner_model if settings and settings.openai_planner_model else "(same)"
    )
    debug_log = "on" if (settings and settings.sentiment_openai_debug) else "off"
    single_only_log = "on" if (settings and settings.sentiment_single_symbol_only) else "off"
    logger.info(
        f"Startup config: symbol={args.symbol or '(none)'}, force={args.force}, OPENAI_MODEL={model_log}, OPENAI_PLANNER_MODEL={planner_model_log}, DEBUG={debug_log}, SINGLE_SYMBOL_ONLY={single_only_log}"
    )
    if not args.symbol:
        logger.info("No on-demand symbol provided; running scheduled mode")
    # Create and run a single event loop for the entire application lifecycle
    try:
        asyncio.run(async_main(symbol=args.symbol, force=args.force))
    except KeyboardInterrupt:
        logger = get_logger(__name__)
        logger.info("Shutting down scheduled stock analysis system...")

if __name__ == "__main__":
    main()
