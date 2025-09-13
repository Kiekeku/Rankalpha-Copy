# RankAlpha Frontend Plan

## Summary
A focused web UI for analysts and operators to explore signals (e.g., momentum), inspect assets, run lightweight what‑ifs, and monitor the data pipeline. Built as a modular Next.js app that consumes the existing REST API and integrates with the Docker Compose stack.

## Users & Goals
- Analyst: Explore signals, compare assets, run quick what‑ifs/backtests.
- Operator: Monitor pipeline health, data freshness, and job runs.
- Admin: Manage environment and access (later phases).

## MVP Pages
- Overview: Today’s status, top/bottom ranked assets, recent pipeline runs.
- Signals Leaderboard: Sort/filter by momentum score, universe/date filters, pagination/export.
- Asset Detail: Price + score charts, drawdowns, stats, latest DB fields.
- Backtest (Lite): Simple rules (top‑N momentum, monthly rebalance), equity curve + core metrics.
- Pipeline Monitor: Link to Airflow UI, last run status/timestamps, data freshness checks.
- Data Browser (Read‑only): Peek tables exposed by the API, with safe presets.

## Tech Stack
- Framework: Next.js + TypeScript + React Query (or SWR) for API data caching.
- UI/Charts: shadcn/ui (Radix) + Tailwind CSS; Lightweight‑Charts or Recharts.
- API Types: Generate from backend `openapi.json` (e.g., `openapi-typescript`).
- Alternative rapid prototype: Streamlit (for quick validation before full React build).

## Data Integration
- Source: FastAPI backend (OpenAPI at `/openapi.json`).
- CRUD: API mounts routers for each SQLAlchemy table; prefer server‑side filters/sorts and pagination.
- State: React Query caching, retries, background refresh; incremental loading over full dumps.

## Auth & Access
- Phase 1: Intranet/basic auth behind a reverse proxy.
- Phase 2: OAuth/OIDC (Auth0/Azure AD) with role gating (Analyst/Operator/Admin).

## Deployment
- Compose: Add a `frontend` service to `compose/docker-compose.yml`, map port `3000`, `depends_on` backend.
- Config: `API_BASE_URL` via env; prod build served by Node or exported/static behind Nginx.

## Nice‑To‑Haves (Post‑MVP)
- Portfolio Builder: Constraints, weights from signals, rebalancing cadence.
- Signal Explorer: Parameter sweeps, correlation heatmaps, signal comparisons.
- Data Quality: Gaps, anomalies, missingness over time.

---

## Phase Plan & Steps

### Phase 0 — Discovery and API Contract
1) Inventory available endpoints and parameters; identify pagination/filtering patterns.
2) Add or adjust server pagination/filter endpoints if required for UX.
3) Export `openapi.json` and generate TypeScript types (`openapi-typescript`).

Deliverables: API capability matrix, generated client types, gaps list (if any).

### Phase 1 — Frontend Scaffold and Foundations
1) Create Next.js app (`apps/frontend` or `docker/app_frontend`).
2) Add Tailwind + shadcn/ui; set up app-wide layout/navigation.
3) Configure env (`API_BASE_URL`), Axios/fetch client, and React Query provider.
4) Wire CI checks (typecheck, lint, build) locally; optional GitHub Actions later.

Deliverables: Running shell app with styling, typed API client wiring.

### Phase 2 — Signals Leaderboard (MVP First Feature)
1) Fetch scores with pagination, sort, and filters (universe/date).
2) Data table with sticky headers, server-driven sorting/filters, CSV export.
3) Empty/loading/error states; basic tests.

Deliverables: Usable leaderboard tied to live API.

### Phase 3 — Asset Detail
1) Route by symbol; fetch price series and momentum series.
2) Charts for price and score; summary stats (returns, drawdown, vol).
3) Recent DB fields section; link back to leaderboard.

Deliverables: Asset page with charts and summary metrics.

### Phase 4 — Backtest (Lite)
1) Simple strategy form: top‑N by momentum, monthly rebalance, optional exclusions.
2) Run via backend endpoint (initially synchronous) or compute client‑side if feasible.
3) Render equity curve and core stats (CAGR, Sharpe, max DD, win rate).

Deliverables: Basic what‑if capability for analysts.

### Phase 5 — Pipeline Monitor
1) Compact dashboard cards for ingestion/scorer last run time/status.
2) Data freshness indicators (e.g., last available date vs today).
3) Deep link to Airflow web UI for details.

Deliverables: Operator‑oriented at‑a‑glance status page.

### Phase 6 — Data Browser (Read‑only)
1) Paginated views for key tables (read‑only).
2) Safe preset filters; no arbitrary SQL.
3) Download CSV for small result sets.

Deliverables: Simple, safe data exploration.

### Phase 7 — Authentication & Authorization
1) Phase 1 auth (reverse proxy/basic) or local guard pages.
2) Phase 2 OIDC integration and role‑based gating for pages/actions.

Deliverables: Secure access aligned to roles.

### Phase 8 — CI/CD and Deployment
1) Add `frontend` service to Docker Compose; environment variables; healthchecks.
2) Build optimization, image size checks, and caching.
3) Optionally add GitHub Actions for build/test/lint and image publish.

Deliverables: Repeatable deploy in the existing stack.

---

## Risks & Mitigations
- API pagination/filters insufficient: augment backend endpoints early (Phase 0).
- Data volume in browser: enforce server‑side pagination and column selection.
- Chart performance: prefer Lightweight‑Charts; virtualize lists where needed.
- Auth complexity: start with reverse proxy/basic; defer OIDC until MVP stabilized.

## Success Criteria
- Analysts can rank/filter assets and inspect an asset’s score/price history.
- Operators can see pipeline status and data freshness at a glance.
- Backtest Lite returns results in < 5 seconds for typical parameters.
- Frontend deploys with the compose stack and is configurable via env.

