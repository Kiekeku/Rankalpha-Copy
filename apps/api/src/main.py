from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import DeclarativeMeta

from apps.common.src.models import Base                                    # ← your huge registry
from .settings import Settings
from .router_factory import build_router
from .http_cache import RedisHTTPCacheMiddleware
from .request_logging import RequestLoggingMiddleware
from .cache import ping_redis, disable_cache_globally
from apps.common.src.logging import get_logger
from .routers import grading, signals, backtest, pipeline, ai_analysis, screener
from .routers import technicals

app = FastAPI(
    title="RankAlpha Data‑Lake",
    version="0.2.0",
    openapi_url="/openapi.json",
    docs_url="/",
    description="RankAlpha API for financial analysis, grading, and backtesting"
)

from .settings import Settings as APISettings
_s = APISettings()
logger = get_logger("api")
if _s.log_level:
    import logging as _logging
    try:
        logger.setLevel(getattr(_logging, _s.log_level.upper(), _logging.INFO))
    except Exception:
        logger.setLevel(_logging.INFO)

# Add CORS middleware for frontend (env-driven with sensible defaults)
settings = Settings()
default_origins = ["http://localhost:3000", "http://localhost:3001"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins or default_origins,
    allow_credentials=settings.cors_allow_credentials,
    allow_methods=settings.cors_allow_methods or ["*"],
    allow_headers=settings.cors_allow_headers or ["*"],
)

# Request logging and global GET cache (Redis)
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(RedisHTTPCacheMiddleware)

# Include custom routers
app.include_router(grading.router)
app.include_router(signals.router)
app.include_router(backtest.router)
app.include_router(pipeline.router)
app.include_router(ai_analysis.router)
app.include_router(screener.router)
app.include_router(technicals.router)

# Startup health probe for Redis cache – disables cache if unreachable
@app.on_event("startup")
async def _startup_health():
    try:
        if not ping_redis():
            disable_cache_globally()
            logger.warning("HTTP cache disabled: Redis not reachable in startup probe")
        else:
            logger.info("HTTP cache enabled: Redis reachable")
    except Exception:
        disable_cache_globally()
        logger.warning("HTTP cache disabled: Redis probe raised exception")

# -------------------------------------------------------------------------
#   Dynamically build + mount a router for **every** SQLAlchemy class
#   – views come out read‑only; ordinary tables get full CRUD.
# -------------------------------------------------------------------------
for mapper in Base.registry.mappers:
    sa_cls: DeclarativeMeta = mapper.class_
    # skip the synthetic relationship‑only helpers (no __table__)
    if getattr(sa_cls, "__table__", None) is None:
        continue
    app.include_router(build_router(sa_cls))
