from __future__ import annotations

import json
import hashlib
from typing import Any, Optional
import socket

import redis

from .settings import Settings


_redis_client: Optional[redis.Redis] = None
_cache_disabled: bool = False


def _get_client() -> redis.Redis:
    global _redis_client
    if _redis_client is not None:
        return _redis_client
    settings = Settings()
    # Configure small timeouts so missing Redis doesn’t stall local dev
    common_kwargs = dict(
        decode_responses=True,
        socket_connect_timeout=0.1,
        socket_timeout=0.2,
        retry_on_timeout=False,
        health_check_interval=0,
    )
    if settings.redis_url:
        _redis_client = redis.from_url(settings.redis_url, **common_kwargs)
    else:
        host = settings.redis_host or "localhost"
        port = int(settings.redis_port or 6379)
        # Optional best-effort DNS probe to avoid long getaddrinfo delays
        try:
            socket.getaddrinfo(host, port)
        except Exception:
            raise ConnectionError(f"Redis host not resolvable: {host}")
        _redis_client = redis.Redis(
            host=host,
            port=port,
            db=int(settings.redis_db or 0),
            password=settings.redis_password or None,
            **common_kwargs,
        )
    return _redis_client


def make_key(prefix: str, params: dict[str, Any]) -> str:
    """Create a stable cache key based on a prefix and params dict."""
    # Sort keys for stability and hash long payloads
    items = sorted((k, params[k]) for k in params)
    raw = json.dumps(items, separators=(",", ":"), ensure_ascii=False)
    digest = hashlib.md5(raw.encode("utf-8")).hexdigest()
    return f"{prefix}:{digest}"


def get_json(key: str) -> Optional[Any]:
    global _cache_disabled
    if _cache_disabled:
        return None
    try:
        val = _get_client().get(key)
        return json.loads(val) if val else None
    except Exception:
        # Disable cache for the remainder of the process to avoid repeated stalls
        _cache_disabled = True
        return None


def set_json(key: str, value: Any, ttl_secs: Optional[int] = None) -> None:
    global _cache_disabled
    if _cache_disabled:
        return
    try:
        payload = json.dumps(value, default=str)
        if ttl_secs and ttl_secs > 0:
            _get_client().setex(key, ttl_secs, payload)
        else:
            _get_client().set(key, payload)
    except Exception:
        _cache_disabled = True
        # best-effort cache; ignore failures
        pass


def invalidate_prefix(prefix: str) -> int:
    """Delete keys starting with a given prefix. Returns number of keys deleted."""
    if _cache_disabled:
        return 0
    try:
        client = _get_client()
        # Use SCAN to avoid blocking
        total = 0
        cursor = 0
        pattern = f"{prefix}*"
        while True:
            cursor, keys = client.scan(cursor=cursor, match=pattern, count=500)
            if keys:
                total += client.delete(*keys)
            if cursor == 0:
                break
        return total
    except Exception:
        return 0


def ping_redis() -> bool:
    """Best-effort ping to Redis with small timeouts.

    Returns True if a ping succeeds; otherwise sets a process-wide
    disable flag to avoid future stalls and returns False.
    """
    global _cache_disabled
    if _cache_disabled:
        return False
    try:
        client = _get_client()
        # 'ping' will attempt a connect if not already connected
        ok = client.ping()
        if not ok:
            _cache_disabled = True
        return bool(ok)
    except Exception:
        _cache_disabled = True
        return False


def disable_cache_globally() -> None:
    """Disable cache for the lifetime of this process."""
    global _cache_disabled
    _cache_disabled = True


def is_cache_disabled() -> bool:
    return _cache_disabled
