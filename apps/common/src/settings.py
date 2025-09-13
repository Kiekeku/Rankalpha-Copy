from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Optional

import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ENV = os.getenv("RANKALPHA_ENV", "local")
ENV_DIR = ROOT / "env" / ENV


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Database
    database_name: str
    db_username: str
    password: str
    host: str
    port: int

    # CORS
    cors_origins: Optional[List[str]] = None
    cors_allow_credentials: bool = True
    cors_allow_methods: Optional[List[str]] = None
    cors_allow_headers: Optional[List[str]] = None

    # OpenAI / LLM
    openai_api_key: Optional[str] = None
    openai_model: Optional[str] = None
    openai_max_completion_tokens: Optional[int] = None
    openai_max_tokens: Optional[int] = None
    openai_disable_reasoning: bool = False
    openai_reasoning_effort: Optional[str] = None  # low | medium | high
    openai_planner_model: Optional[str] = None  # optional override for planner-only model

    # Sentiment app toggles
    sentiment_symbol: Optional[str] = None
    sentiment_force: bool = False
    sentiment_openai_debug: bool = False
    sentiment_single_symbol_only: bool = False
    sentiment_log_prompts: bool = False
    sentiment_log_file: Optional[str] = None

    # Paths for sentiment app (helpful for local runs)
    sentiment_data_dir: Optional[str] = None
    sentiment_output_dir: Optional[str] = None
    sentiment_schedule_file: Optional[str] = None

    # Sentiment worker output sizing (GPT-5 Responses)
    sentiment_analyst_max_tokens: Optional[int] = None
    sentiment_writer_max_tokens: Optional[int] = None

    # Sentiment tool behavior
    sentiment_fetch_max_length: Optional[int] = None
    sentiment_tool_cache: bool = True
    sentiment_tool_cache_ttl_seconds: Optional[int] = None
    # Planner/orchestrator tuning
    sentiment_orchestrator_timeout_seconds: Optional[int] = None
    # PDF extraction size cap for EDGAR/generic fetches (characters)
    sentiment_pdf_extract_max_chars: Optional[int] = None

    # Redis cache configuration (for sentiment tool cache)
    redis_url: Optional[str] = None
    redis_host: Optional[str] = None
    redis_port: Optional[int] = None
    redis_db: Optional[int] = None
    redis_password: Optional[str] = None

    # API HTTP cache toggle
    http_cache_enabled: bool = True

    # API cache TTLs (seconds)
    cache_ttl_default: Optional[int] = None
    cache_ttl_rankings: Optional[int] = None
    cache_ttl_stock_detail: Optional[int] = None
    cache_ttl_top_performers: Optional[int] = None
    cache_ttl_sectors: Optional[int] = None

    # Logging
    log_level: Optional[str] = None  # DEBUG, INFO, WARNING, ERROR
    log_slow_request_ms: Optional[int] = None  # warn threshold

    # SEC EDGAR MCP configuration
    sec_edgar_user_agent: Optional[str] = None

    # Consensus screener (optional sentiment integration)
    sentiment_use_consensus: bool = False
    sentiment_consensus_min_appearances: Optional[int] = None
    sentiment_consensus_min_styles: Optional[int] = None
    sentiment_consensus_limit: Optional[int] = None
    sentiment_consensus_batch_only: bool = False
    # Skip re-analysis if there is a recent analysis within N days (default 1 = same-day only)
    sentiment_skip_if_within_days: int = 1

    model_config = SettingsConfigDict(
        env_file=[ENV_DIR / "api.env", ENV_DIR / "ingestion.env", ENV_DIR / "sentiment.env"],
        case_sensitive=False,
        extra="ignore",  # Ignore unrelated keys from shared env files
    )
