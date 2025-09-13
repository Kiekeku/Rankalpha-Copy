from __future__ import annotations

import os
from pathlib import Path

from pydantic_settings import SettingsConfigDict

# Reuse common Settings fields but restrict env_file to API only
from apps.common.src.settings import Settings as _CommonSettings


ROOT = Path(__file__).resolve().parents[3]
ENV = os.getenv("RANKALPHA_ENV", "local")
ENV_DIR = ROOT / "env" / ENV


class Settings(_CommonSettings):
    """API-specific Settings: read only env/{ENV}/api.env.

    This avoids HOST from ingestion/sentiment env files clobbering the API DB host
    when running locally without Docker.
    """

    model_config = SettingsConfigDict(
        env_file=[ENV_DIR / "api.env"],
        case_sensitive=False,
        extra="ignore",
    )

