# Code Review – RankAlpha

## Summary
RankAlpha is a multi-service Python 3.12 project orchestrated with Docker Compose and Airflow. Services are split under `apps/` with a shared `apps/common` package, Postgres migrations under `docker/database/sql/migrations`, and a backend package under `src/rankalpha_backend`. The direction is solid, but there are several integration, configuration, and reliability issues that should be addressed to stabilize local/dev and pipeline runs.

## Strengths
- Clear service boundaries (`ingestion`, `scorer`, future `sentiment`) and Flyway migrations.
- Useful Airflow DAG to orchestrate containerized tasks with a shared `/data/prices` volume.
- Tests exist for core utilities and algorithms (logger, settings, scorer math, ingestion record prep).

## High-Priority Findings
- apps/common/src/settings.py
  - ROOT path uses `parents[4]` which points above repo root; use `parents[3]`.
  - Pydantic v2 config: replace inner `Config` with `model_config = SettingsConfigDict(env_file=[ENV_DIR/"ingestion.env"], case_sensitive=False)`.
  - Consider supporting per-app env files (ingestion/scorer) or a shared `.env` to avoid coupling.
- Logging module naming
  - `apps/common/src/logging.py` shadows the stdlib `logging` module; tests import `from logging import get_logger` relying on this. There is also `sitecustomize.py` that monkey-patches `logging.get_logger`.
  - Recommendation: Rename to `logger.py` (or `logutil.py`) and import explicitly (`from logger import get_logger`). Remove the shadowing + sitecustomize hack to reduce surprise and import ambiguity.
- Schema drift
  - ORM `FactScoreHistory.score` does not match DB column `momentum_value` defined in migrations and used by `scorer`. Align the ORM to `momentum_value` or add a mapped column/property.
- Ingestion robustness (apps/ingestion/src/main.py)
  - Fragile SQL: `SELECT *` then `stocks[i][2]` to get the symbol. Use an explicit `SELECT symbol` and iterate rows.
  - Unused `start_date`; hard-coded `'2024-01-01'` in `yf.download`. Remove unused vars or make `start` configurable.
  - Add exception handling and rate limiting for `yfinance` calls; log failures and continue.
  - Don’t print secrets-containing `Settings`; remove the debug print.
- Imports and packaging
  - Multiple files mutate `sys.path` to find `apps/common/src`. Prefer packaging `apps/common` (it already has a `pyproject.toml`) and installing it per-service via `uv sync --locked` or `uv pip install -e ../common` in Dockerfiles/venvs.
  - Typos: `ingest_nortgate_fundamental.py` (rename to `ingest_norgate_fundamental.py`), `multi_period_analyis` import in `ingest_fundamentals.py`.
- Dependencies
  - Redundant/conflicting DB drivers in `apps/ingestion` and `apps/scorer` (`psycopg`, `psycopg-binary`, `psycopg2`, `psycopg2-binary`). Choose one stack (prefer `psycopg[binary]` for v3) and remove the rest.
- Airflow/Compose networking
  - Compose declares `rankalpha_backend_network` with `name: rankalpha_net` and `external: true`. Airflow DAG uses `network_mode='rankalpha_backend_network'`. At runtime the actual Docker network name is `rankalpha_net` and must exist beforehand. Either remove `external: true` or update the DAG to `rankalpha_net` and document creating it (`docker network create rankalpha_net`).

## Medium-Priority
- apps/common/src/crud.py uses env names (`DB_USER`, `DB_PASSWORD`, etc.) differing from `Settings` (`DB_USERNAME`, etc.). Standardize across the repo.
- `scorer` uses `SOURCE_KEY = 1` constant; consider fetching/ensuring the `dim_source` row and caching the key (similar to ingestion source logic).
- Add basic retry/back-off for DB connections in ingestion/scorer.
- `infra/airflow/README.md` is empty; add runbook notes (env mounts, network name, image tags, local volumes).

## Testing
- Tests mix SimFin constants while code uses EDGAR utilities. Keep the unit test for `_prepare_records`, but remove hard dependency on `simfin` by using plain strings to construct the DataFrame columns.
- Add a smoke test that reads a tiny in-repo parquet and exercises `scorer` functions end-to-end without DB inserts.

## Suggested Next Steps
1) Fix `settings.py` (parents[3], Pydantic v2 `model_config`).
2) Rename `apps/common/src/logging.py` and remove `sitecustomize.py` patching; update imports.
3) Align ORM model `FactScoreHistory` to `momentum_value` and add a migration if needed.
4) Clean imports: remove `sys.path` hacks by packaging/installing `apps/common` in each service.
5) Normalize DB drivers to `psycopg[binary]` and remove `psycopg2*`.
6) Update Airflow DAG `network_mode` or Compose network configuration and document the setup.
7) Harden ingestion/scorer error handling and SQL queries; drop debug prints.
