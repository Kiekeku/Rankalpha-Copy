## 1  Overview

RankAlpha is implemented as a **PostgreSQL data‑warehouse‑style schema**.
It follows a classic **star/constellation** design:

| Layer                      | Purpose                                                                                                                                                       |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Dimensions (`dim_*`)**   | Slow‑changing reference entities (dates, securities, factors, etc.).                                                                                          |
| **Facts (`fact_*`)**       | Time‑series or event tables, usually **compound PK** = `date_key` + surrogate keys. Several big tables are **range‑partitioned by `date_key`** for scale‑out. |
| **Bridge / helper tables** | Narrow tables such as `portfolio_position` that link entities outside the star.                                                                               |
| **Views (`v_*` / `vw_*`)** | Canonical, developer‑friendly SELECTs that hide partitions and joins.                                                                                         |

### Naming conventions

```
<schema>.<prefix>_<noun>    -- e.g. dim_stock, fact_security_price
*_key / *_id                -- surrogate PK
*_pk / *_fk                 -- constraint names
pk_ / fk_ / idx_            -- index names
```

---

## 2  Dimension tables

| Table                                   | One‑liner                                                     | Important columns                                                             |
| --------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **`dim_date`**                          | Calendar & trading calendar lookup.                           | `date_key` (YYYYMMDD int), `full_date`, flags (DOW, month, is\_trading\_day). |
| **`dim_stock`**                         | Master list of instruments.                                   | `symbol`, `company_name`, `sector`, FK `asset_type_key`.                      |
| **`dim_asset_type`**                    | Equity, ETF, ADR… referenced by stocks & trades.              | `asset_type_name`.                                                            |
| **`dim_factor`**                        | Quant factor catalogue.                                       | `model_name`, `factor_name`.                                                  |
| **`dim_style`**                         | Value, Growth, Quality…                                       | `style_name`.                                                                 |
| **`dim_score_type`**                    | ESG, Piotroski, internal AI score labels.                     | `score_type_name`.                                                            |
| **`dim_rating`**                        | Textual ratings bucket (Strong Buy…Sell).                     | `rating_label`.                                                               |
| **`dim_confidence`**                    | Low / Med / High certainty flag.                              | `confidence_label`.                                                           |
| **`dim_timeframe`**                     | Trade horizon tags (1d, 1w, 3m, …).                           | `timeframe_label`.                                                            |
| **`dim_trend_category`**                | Generic trend up/flat/down buckets used by margin trends etc. | `trend_label`.                                                                |
| **`dim_benchmark`**                     | Reference indices (S\&P 500, NASDAQ100…).                     | `benchmark_name`, `currency_code`.                                            |
| **`dim_tenor`**                         | 1D–30Y buckets for IV & risk‑free curves.                     | `tenor_days`, `tenor_label`.                                                  |
| **`dim_corr_method / dim_corr_window`** | How correlations were measured.                               | `corr_method_name`, `window_days`.                                            |
| **`dim_fin_metric`**                    | Raw statement field dictionary.                               | `metric_code`, `metric_name`, `stmt_code`.                                    |
| **`dim_source`**                        | Data‑ingestion provenance (vendor + version).                 | `source_name`, `version`.                                                     |
| **`dim_var_method`**                    | VaR methodologies.                                            | `method_label`.                                                               |
| **`dim_stress_scenario`**               | Historical or hypothetical stress‑tests.                      | `scenario_name`, `severity_label`.                                            |

All dimension PKs are **surrogate serials**, immutable, and referenced everywhere.

---

## 3  Fact tables (by domain)

### 3.1 Market & fundamental data

| Table                        | Grain                                    | Highlights                                                                                   |
| ---------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------------- |
| **`fact_security_price`**    | Daily bar per stock.                     | OHLCV + `total_return_factor`.                                                               |
| **`fact_benchmark_price`**   | Daily bar per index.                     | Mirrors above for benchmarks.                                                                |
| **`fact_fin_fundamentals`**  | *As‑reported* & TTM metrics.             | Range‑partitioned; unique `(date_key, stock_key, metric_key)`; flags `restated`, `ttm_flag`. |
| **`fact_factor_return`**     | Daily factor returns.                    | FK `factor_key`.                                                                             |
| **`fact_fx_rate`**           | Daily FX mid rates.                      | `(from_ccy, to_ccy)` composite PK.                                                           |
| **`fact_risk_free_rate`**    | Daily RFR term‑structure.                | FK `tenor_key`.                                                                              |
| **`fact_iv_surface`**        | Implied vol cube (date × stock × tenor). | Useful for options analytics.                                                                |
| **`fact_stock_borrow_rate`** | Daily securities‑lending borrow bp.      | —                                                                                            |
| **`fact_stock_correlation`** | Pairwise correlations.                   | Symmetry enforced by `chk_stock_order`, FK to method/window dimensions, plus `corr_runid`.   |

### 3.2 AI / analytics output

| Table                                                                 | Purpose                                                                                                                                |
| --------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **`fact_ai_stock_analysis`**                                          | **Core AI thesis** for a stock on a day. Holds \~50 fields (margins, sentiment, rating, betas, commentary…). Range‑partitioned yearly. |
| **`fact_ai_factor_score`**                                            | Style‑level AI scores per analysis run.                                                                                                |
| **`fact_ai_peer_comparison`**                                         | Valuation & perf peer snapshot.                                                                                                        |
| **`fact_ai_catalyst` / `fact_ai_price_scenario`**                     | Event list & bull/base/bear price targets with probability.                                                                            |
| **`fact_ai_data_gap`, `fact_ai_headline_risk`, `fact_ai_macro_risk`** | Free‑text notes describing missing data and risk flags.                                                                                |
| **`fact_ai_valuation_metrics`**                                       | Convenience table of forward‐multiples and percentiles.                                                                                |

### 3.3 Scoring & screening

| Table                                            | Description                                                        |
| ------------------------------------------------ | ------------------------------------------------------------------ |
| **`fact_score_history`**                         | Time‑series of third‑party or internal scores.                     |
| **`fact_screener_rank`**                         | Rank order in saved screen runs (PK uses `fact_id` to allow ties). |
| **`fact_stock_scores / fact_stock_score_types`** | Detailed per‑style score values and per‑score‑type values.         |

### 3.4 Portfolio management

| Table                                           | Function                                                        |
| ----------------------------------------------- | --------------------------------------------------------------- |
| **`portfolio`**                                 | Master entity; cascades on delete.                              |
| **`portfolio_position`**                        | Current live positions (one row per symbol).                    |
| **`fact_portfolio_position_hist`**              | Daily snapshot for backfills (effective\_date).                 |
| **`fact_portfolio_nav` / `fact_portfolio_pnl`** | NAV history & P/L decomposition.                                |
| **`fact_portfolio_trade`**                      | Executed trades; check constraint ensures `side` ∈ {BUY, SELL}. |
| **`fact_portfolio_factor_exposure`**            | Daily factor betas.                                             |
| **`fact_portfolio_var`**                        | VaR / ES per method / horizon.                                  |
| **`fact_portfolio_risk`**                       | Misc custom metrics (liquidity days, beta, etc.).               |
| **`fact_portfolio_scenario_pnl`**               | Stress P/L versus scenarios.                                    |

### 3.5 News & sentiment

| Table                     | Notes                                                         |
| ------------------------- | ------------------------------------------------------------- |
| **`fact_news_articles`**  | Raw articles; partitioned; FK to `dim_source`.                |
| **`fact_news_sentiment`** | One‑to‑one with article via PK `article_id`; scores + labels. |

### 3.6 Corporate events

| Table                           | Purpose                                                   |
| ------------------------------- | --------------------------------------------------------- |
| **`fact_corporate_action`**     | Splits, dividends, spinoffs (generic `ratio_or_amt`).     |
| **`fact_trade_recommendation`** | AI or analyst trade calls; trigger maintains `update_ts`. |

---

## 4  Views

All production queries should target **views**; they de‑partition fact tables and enrich them with dimension text:

* `vw_fin_fundamentals`, `vw_iv_surface`, `vw_stock_style_scores`, `vw_news_sentiment` – ready for BI tools.
* `v_latest_screener / v_latest_screener_values` – one‑liner “top picks”.
* Portfolio dashboards: `vw_portfolio_snapshot`, `vw_portfolio_performance`, `vw_risk_dashboard`, etc.

These views **JOIN dimensions, aggregate when useful, and expose human‑readable field names** so application code rarely touches base facts.

---

## 5  Partitioning & indexing strategy

* **Large time‑series facts** (`*_analysis`, `*_fundamentals`, `*_articles`, `*_score_history`) are **range‑partitioned by `date_key`** (year or month depending on volume).

  * Child tables inherit PK & FK constraints; automatic indexes are shown in DDL.
* **Compound primary keys** keep rows unique and serve as cluster indexes.
* Secondary indexes focus on the most common filters (`stock_key`, `style_key`, `score_type_key`, `screening_runid`, etc.).
* **Foreign keys are always on surrogate integers** to keep joins fast.

---

## 6  How it all fits together

1. **Ingestion** drops reference data into dimensions first (stocks, dates, factors, …).
2. Market data, fundamentals and AI pipelines populate fact tables daily.
3. Portfolio engine writes trades/NAV/risk in (near) real‑time.
4. Analysts & dashboards read from the **vw\_**\* views – never from partitions directly.
5. Scheduled archivers can detach old partitions without breaking views.

---

## 7  Example query patterns

```sql
-- Last close & AI rating for a ticker
SELECT d.full_date, sp.close_px, r.rating_label
FROM vw_trade_recommendation tr
JOIN dim_stock s USING (symbol)
JOIN dim_date d ON d.date_key = tr.date_key
JOIN dim_rating r ON r.rating_key = tr.rating_key
WHERE s.symbol = 'AAPL'
  AND tr.is_live = true
ORDER BY d.full_date DESC
LIMIT 1;
```

```sql
-- Portfolio factor exposure on a given day
SELECT *
FROM vw_portfolio_factor_exposure
WHERE portfolio_name = 'Flagship Equity'
  AND exposure_date = '2025‑06‑30';
```

---

## 8  Extending the model

* **Add a new factor** → insert into `dim_factor`, then start writing into `fact_factor_return` and `fact_portfolio_factor_exposure`.
* **Add a new AI metric** → extend `fact_ai_stock_analysis` (and matching view) – keep nullable for backward compatibility.
* **New portfolio** → insert into `portfolio`; FKs ensure cascaded risk/PnL records.

---

### Final tips for contributors

* Follow existing naming & FK patterns; every table must reference a **date dimension** unless it is timeless.
* Keep wide facts **immutable** – never update historical rows; write new rows instead.
* Use `source_key` everywhere external data enters the warehouse for lineage.
* If you add a big fact table, **partition by `date_key`** unless you have a very good reason not to.

---

