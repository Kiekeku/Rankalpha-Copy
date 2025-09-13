# Repository Guidelines

## Project Structure & Module Organization
- `apps/ingestion`: Fetches historical prices (e.g., yfinance) and writes parquet to `/data/prices`.
- `apps/scorer`: Reads price data and writes momentum scores to Postgres.
- `apps/sentiment`: Placeholder for future agents.
- `apps/api`: FastAPI backend exposing domain routers plus auto-generated CRUD over data models.
- `apps/frontend`: Next.js 14 web UI that consumes the API; runs on port 3000.
- `infra/airflow/dags/pipeline.py`: Orchestrates ingestion and scorer containers.
- `docker/`: Dockerfiles; DB migrations in `docker/database/sql/migrations`.
- `compose/docker-compose.yml`: Builds and connects services.
- `tests/`: Pytest suite (currently minimal).

## Build, Test, and Development Commands
- Environment: Python 3.12; manage deps with `uv` per app.
- Bootstrap a service: `cd apps/<service> && uv venv && uv sync --locked`.
- Run full stack: `docker compose -f compose/docker-compose.yml up --build`.
- Tests: from project root, `pytest`.

### Service development (local)
- API (FastAPI):
  - `cd apps/api && uv venv && uv sync --locked`
  - Ensure imports resolve: `export PYTHONPATH=../..` (Linux/macOS) or `$env:PYTHONPATH='../..'` (PowerShell)
  - Run: `uv run uvicorn src.main:app --reload --port 6080`
- Frontend (Next.js):
  - `cd apps/frontend && pnpm install`
  - Ensure backend is reachable: `NEXT_PUBLIC_API_URL=http://localhost:6080`
  - Run: `pnpm dev` (opens http://localhost:3000)

## Coding Style & Naming Conventions
- Style: PEP 8; write small, single-purpose functions with clear docstrings.
- Types: Prefer type hints for public functions and data models.
- Naming: modules `lower_snake_case`; classes `CamelCase`; functions/vars `lower_snake_case`.
- Structure: Keep app services independent; shared backend code lives under `src/`.
- Frontend: Use TypeScript with React; follow Next.js App Router conventions; keep components small and typed.

## Testing Guidelines
- Framework: `pytest`.
- Location & names: place tests in `tests/` and name files `test_*.py`.
- Expectations: keep the suite passing; add focused tests when introducing new logic or pipelines.
- Scope: favor fast unit tests; mark slow/integration cases explicitly if added.

Frontend:
- Type checking: `pnpm type-check`.
- Linting: `pnpm lint`.

## Repository layout
- `apps/`
  - `api/` – FastAPI service exposing auto-generated CRUD endpoints over the data models.
  - `common/` – shared utilities and data models used across apps.
  - `ingestion/` – downloads historical prices with yfinance and saves them to `/data/prices`.
  - `scorer/` – reads those parquet files and writes momentum scores to Postgres.
  - `sentiment/` – placeholder for future sentiment analysis agents.
  - `frontend/` – Next.js application (UI) consuming the API.
- `src/` – shared code for other services (no standalone backend container).
- `infra/airflow/` – Airflow DAG (`dags/pipeline.py`) orchestrating the `ingestion` and `scorer` containers.
- `docker/` – Dockerfiles for the backend, Redis cache, and Postgres database. Migrations live in `docker/database/sql/migrations`.
- `compose/` – `docker-compose.yml` that builds and connects all services including Airflow.
- `tests/` – pytest test suite (currently empty).

## Running
- There is no single top-level `main.py`. Run services individually from their app directories or run the full stack with Docker.
- Full stack via Docker Compose:
  ```bash
  docker compose -f compose/docker-compose.yml up --build
  ```
- Local examples (per app), after `uv venv && uv sync --locked` in that app directory:
  - Ingestion: `uv run python src/main.py`
  - Scorer: `uv run python src/main.py`
  - Sentiment: `uv run python src/main.py`
  - API (dev): `uv run uvicorn src.main:app --reload --port 6080` (ensure your `PYTHONPATH` includes the repo root so imports like `apps.common` resolve; running from the project root with `PYTHONPATH=.` is one option.)
  - Frontend (dev): from `apps/frontend`, set `NEXT_PUBLIC_API_URL=http://localhost:6080` and run `pnpm dev`.

### Docker Compose services
- `api`: FastAPI on `6080` (docs at `/`).
- `frontend`: Next.js on `3000`, depends on `api` and uses `NEXT_PUBLIC_API_URL=http://api:6080` inside the network.
- `database`: PostgreSQL with Flyway migrations via `flyway` service.
- `cache`: Redis for caching.
- `airflow-*`: Orchestrates the pipeline and can trigger frontend refresh via internal hooks.

## Commit & Pull Request Guidelines
- History shows mixed styles; adopt Conventional Commits going forward (e.g., `feat:`, `fix:`, `docs:`, `test:`).
- Messages: imperative subject (≤ 50 chars), optional body explaining what/why; reference issues (e.g., `#123`).
- PRs: include summary, scope of changes, local run/test instructions, and DB migration notes if applicable; ensure `pytest` passes and services build.

## Security & Configuration Tips
- Secrets: never commit credentials; use env vars or Docker secrets.
- Data: ingestion writes to `/data/prices`; mount volumes accordingly when running containers.
- Database: apply migrations from `docker/database/sql/migrations`; verify schema updates before deploys.
- Airflow: update `infra/airflow/dags/pipeline.py` when adding or reordering pipeline steps.
- CORS: ensure API `allow_origins` includes frontend URLs (e.g., http://localhost:3000). In Docker, the compose file sets frontend’s `NEXT_PUBLIC_API_URL` to `http://api:6080`.

## Notes on API & Frontend Integration
- API docs available at `http://localhost:6080/` (Swagger UI) when running locally.
- Frontend expects `NEXT_PUBLIC_API_URL` to point at the API base URL.
- To generate frontend API types from OpenAPI: `pnpm generate-types` (requires API running at the configured URL).
