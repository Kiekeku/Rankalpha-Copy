from __future__ import annotations

import json
from typing import Callable

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.responses import Response, JSONResponse

from .settings import Settings
from .cache import make_key, get_json, set_json, ping_redis, is_cache_disabled


def _ttl_for_path(path: str, settings: Settings) -> int:
    # Specific TTLs for known heavy endpoints
    if path.startswith("/api/v1/grading/grades"):
        return int(settings.cache_ttl_rankings or 300)
    if path.startswith("/api/v1/grading/sectors"):
        # sectors change infrequently – cache longer
        return int(getattr(settings, "cache_ttl_sectors", None) or 3600)
    if path.startswith("/api/v1/grading/asset/") or path.startswith("/api/v1/grading/grades/"):
        return int(settings.cache_ttl_stock_detail or 600)
    if path.startswith("/api/v1/ai-analysis"):
        return int(settings.cache_ttl_top_performers or 300)
    # Fallback default
    return int(getattr(settings, "cache_ttl_default", None) or 180)


class RedisHTTPCacheMiddleware(BaseHTTPMiddleware):
    """Simple read‑through cache for idempotent GET endpoints.

    - Caches JSON 200 responses in Redis keyed by method+path+sorted query.
    - Honors per‑path TTLs; default TTL if none specified.
    - Skips caching if the client sends Cache-Control: no-cache.
    - Skips caching for refresh/invalidation endpoints.
    """

    def __init__(self, app):
        super().__init__(app)
        self.settings = Settings()
        self.enabled = bool(getattr(self.settings, "http_cache_enabled", True))
        if self.enabled:
            # tiny health probe – if Redis not reachable, disable middleware
            try:
                if not ping_redis():
                    self.enabled = False
            except Exception:
                self.enabled = False

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        # Allow disabling via env for local dev
        if not self.enabled or is_cache_disabled():
            return await call_next(request)
        # Only cache GETs and allow opt-out
        if request.method != "GET":
            return await call_next(request)

        if "no-cache" in request.headers.get("Cache-Control", "").lower():
            return await call_next(request)

        # Skip caching for refresh endpoint (explicit invalidation path)
        if request.url.path.startswith("/api/v1/grading/refresh"):
            return await call_next(request)

        # Build cache key from path and sorted query params
        params = dict(sorted(request.query_params.multi_items()))
        key = make_key(f"httpcache:{request.method}:{request.url.path}", params)

        cached = get_json(key)
        if cached is not None:
            # Assume JSON payload and 200 OK
            return JSONResponse(content=cached, status_code=200)

        # No cache – execute request
        response = await call_next(request)

        # Cache only JSON 200 responses
        ctype = (response.media_type or "").lower()
        if response.status_code == 200 and "application/json" in ctype:
            try:
                # JSONResponse has .body bytes available
                body_bytes = response.body
                if body_bytes is None:
                    # Consume body_iterator if needed
                    body_chunks = [chunk async for chunk in response.body_iterator]  # type: ignore[attr-defined]
                    body_bytes = b"".join(body_chunks)
                    # rebuild response so it can be sent to client
                    response = Response(content=body_bytes, media_type=response.media_type, status_code=response.status_code)

                payload = json.loads(body_bytes.decode("utf-8")) if body_bytes else None
                if payload is not None:
                    ttl = _ttl_for_path(request.url.path, self.settings)
                    set_json(key, payload, ttl_secs=ttl)
            except Exception:
                # ignore cache errors and continue
                pass

        return response
