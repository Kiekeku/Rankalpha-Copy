## 🖥  Local development (Windows)

# 1. Hardware
* **CPU**  ≥ 8 cores  
* **RAM**  32 GB  
* **Disk**  1 TB SSD  

# 2. Base software
* **WSL 2** (Ubuntu recommended)
* **Docker Desktop** with WSL integration enabled
* **VS Code** + extensions  
  * Python (ms-python)  
  * Mermaid Preview (bierner.mermaid-markdown)
* **Node.js 18+** (for frontend dev)

# 3. Python toolchain
All services target Python 3.12 and use Astral `uv` for dependency management.

```
powershell
# Install Astral uv  (~3 s, no admin)
irm https://astral.sh/uv/install.ps1 | iex
```

# 4. Quick Start with Docker (Recommended)

For the fastest setup, use Docker Compose to run the complete stack:

```powershell
# Navigate to compose directory
cd compose

# Start all services (API, Frontend, Database, etc.)
docker compose up --build

# Access the applications:
# Frontend: http://localhost:3000
# API: http://localhost:6080  
# API Docs: http://localhost:6080/
```

See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for detailed Docker instructions.

# First Run: Load Initial Data

On a fresh database, the API’s grading endpoints return HTTP 200 with an empty result until the pipeline ingests data. Choose one of the following to seed data:

- Full stack (recommended):
  - `docker compose -f compose/docker-compose.yml up --build`
  - Airflow auto‑triggers the initial pipeline; first run can take several minutes.
  - Check Airflow UI at http://localhost:8080 for DAG progress.

- API‑only development (minimal services):
  1) Start DB and apply migrations
     - `docker compose -f compose/docker-compose.yml up -d database flyway`
  2) Run ingestion to populate price data volume
     - `docker compose -f compose/docker-compose.yml up ingestion`
  3) Run scorer to write scores to Postgres
     - `docker compose -f compose/docker-compose.yml up scorer`

Once ingestion/scorer complete, refresh the frontend (http://localhost:3000). The grading and pipeline views will populate.

Optional – run Sentiment to enrich data:
- Sentiment adds AI factor scores (value/sentiment), news analysis, and richer asset detail. Without it, those fields show as N/A and the pipeline may show a warning for the sentiment component.
- Start it anytime:
  - `docker compose -f compose/docker-compose.yml up sentiment`

Technical indicators
- Ingestion writes price Parquets under `/data/prices` and keeps them fresh by incrementally updating from yfinance when needed (weekends/holidays create no new rows; files remain as-is).
- After ensuring Parquet freshness, ingestion computes daily technical indicators and upserts them to Postgres (`rankalpha.fact_technical_indicator`).
- A convenience view `rankalpha.vw_latest_technicals` provides a pivoted snapshot per symbol.

# 5. Manual Development Setup

This repo is multi-service. Each app under `apps/` has its own `pyproject.toml`, `uv.lock`, and virtual environment. Set up the ones you plan to work on:

```powershell
# API (FastAPI backend)
cd apps\api
uv venv
uv sync --locked

# Frontend (Next.js)
cd ..\frontend
pnpm install

# Ingestion
cd ..\ingestion
uv venv
uv sync --locked

# Scorer
cd ..\scorer
uv venv
uv sync --locked

# Sentiment (optional)
cd ..\sentiment
uv venv
uv sync --locked
```

Activating is optional when using `uv run`, but you can still activate a venv if preferred:

```
.venv\Scripts\Activate   # Windows (from each app directory)
# or
source .venv/bin/activate # WSL/Linux/macOS
```

# 5. VS Code 
Ctrl ⇧ P → Python: Select Interpreter → choose
the `.venv\Scripts\python.exe` inside the specific app you’re working on (e.g., `apps\ingestion\.venv\Scripts\python.exe`).

# 6. Day-to-day package management (per app)
Run dependency commands inside the target app directory so its `uv.lock` is updated correctly.

```
uv add <pkg>
uv remove <pkg>
git add pyproject.toml uv.lock
git commit -m "deps: update <app>"
```

# 7. House-Keeping
`uv sync`            # refresh env after pulling changes

`uv self update`     # update uv itself


# Running locally (per app)

There is no single top-level `main.py`. Examples:

- Ingestion: from `apps/ingestion` → `uv run python src/main.py`
- Scorer: from `apps/scorer` → `uv run python src/main.py`
- Sentiment: from `apps/sentiment` → `uv run python src/main.py`
- API (dev): from `apps/api` → set `PYTHONPATH` to the repo root, then run uvicorn
  - PowerShell: `$env:PYTHONPATH = '..\\..' ; uv run uvicorn src.main:app --reload`
  - Bash: `export PYTHONPATH=../.. && uv run uvicorn src.main:app --reload`
- Frontend (dev): from `apps/frontend` → set `NEXT_PUBLIC_API_URL` to the API base URL, then run
  - PowerShell: `$env:NEXT_PUBLIC_API_URL='http://localhost:6080' ; pnpm dev`
  - Bash: `NEXT_PUBLIC_API_URL=http://localhost:6080 pnpm dev`

## Frontend (pnpm quick reference)

Prerequisite: Node.js 18+.

Enable pnpm via Corepack (recommended):

```
# Bash / WSL / macOS
corepack enable && corepack prepare pnpm@9.12.3 --activate

# PowerShell
corepack enable; corepack prepare pnpm@9.12.3 --activate
```

Common commands (run in `apps/frontend`):

```
pnpm install                  # install deps
pnpm dev                      # start Next.js dev server (http://localhost:3000)
pnpm build && pnpm start      # production build and start
pnpm type-check               # TypeScript check
pnpm lint                     # ESLint
pnpm generate-types           # generate API types from FastAPI OpenAPI
```

# Docker build

1. Start command line / terminal
2. Go to the project root folder (e.g.`c:\...\rankalpha`)
3. Build and start the services:
 ```docker compose -f compose\docker-compose.yml up --build```
4. If need to force a full rebuild of the images, including remove volumes: 
```docker compose -f compose\docker-compose.yml down -v
docker compose -f compose\docker-compose.yml up --build
```
5. To update the database
`docker compose -f compose\docker-compose.yml up flyway`

## Database:
- Schema is `rankalpha`

## To set the correct env folder on local dev:

On your local dev machine, some services (e.g., the database) use different host/port (e.g., `localhost:6543`) versus Docker-internal names (e.g., `database:5432`). There is a folder under `/env` called `localws` for “outside looking in” development.

For development/debugging outside Docker, set the environment folder as below to ensure your code targets the running containers. The settings classes look under `/env`. If `RANKALPHA_ENV` is not specified, `local` is used by default.

- run on bash:  
      export RANKALPHA_ENV=localws
       
 - run on powershell: 
      $env:RANKALPHA_ENV = "localws"
        
## Ingestion app

From `rankalpha\apps\ingestion`:

```
uv run python src/main.py

Notes:
- Parquet freshness check: existing files are updated incrementally from the last available date to today.
- Daily technical indicators are computed from Parquet and upserted to Postgres (see `vw_latest_technicals`).
```

## Sentiment app (local setup)

Recommended: run via Docker Compose (no local installs required)

- Set your OpenAI key in `env/local/sentiment.env` (or the env folder you use):
  - `OPENAI_API_KEY=sk-...`
- Start the service:
  - `docker compose -f compose/docker-compose.yml up sentiment`

Local run (outside Docker)

Prerequisites:
- Python 3.12 and Astral uv
- Node.js 18+
- Global MCP server for Google Search: `npm install -g g-search-mcp`
- Playwright Chromium browser: from `apps/sentiment`, run `uv run python -m playwright install chromium`

Environment:
- Copy `env/example/sentiment.env.example` to your env folder and fill values (at minimum `OPENAI_API_KEY`).
- Ensure your Settings target the right env folder: `export RANKALPHA_ENV=local` (or `localws`).
- For DB outside Docker, host is usually `localhost` and port `6543` (Compose maps `6543:5432`).
 - Model selection: set the default model in `apps/sentiment/src/mcp_agent.config.yaml` under `openai.default_model`, and optionally override with `OPENAI_MODEL` in your env (env precedence beats config; there is no hardcoded fallback).

Data directories (Linux/macOS): the app writes to `/data/company_reports` and `/data/analysis_schedule`.
Create them once with write permissions:
```
sudo mkdir -p /data/company_reports /data/analysis_schedule
sudo chmod -R 777 /data
```

Run locally:
```
cd apps/sentiment
uv venv && uv sync --locked
uv run python src/main.py
```

Notes:
- The app warns if `OPENAI_API_KEY` is not set and will skip AI analysis.
- In Compose, volumes for `/data/company_reports` and `/data/analysis_schedule` are mounted automatically.
