from __future__ import annotations
import os, sys, time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Iterable, List, Set
import re
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values

from edgar import set_identity, Company,MultiFinancials
from multi_period_analyis import retrieve_multi_year_data
from edgar_analytics.data_utils           import parse_period_label


# ––– Project plumbing ––––––––––––––––––––––––––––––––––––––––––
HERE        = Path(__file__).resolve().parent
COMMON_SRC  = HERE.parents[1] / "common" / "src"
if str(COMMON_SRC) not in sys.path:
    sys.path.insert(0, str(COMMON_SRC))

from logging  import get_logger
from settings import Settings


# ––– Constants ––––––––––––––––––––––––––––––––––––––––––––––––
YEARS_BACK        = 1#15
QUARTERS          = YEARS_BACK * 4
PAUSE_SEC_DEFAULT = 0.25
CHUNK_SIZE        = 50


# ––– Helpers ––––––––––––––––––––––––––––––––––––––––––––––––––
def _derive_code(name: str, max_len: int = 12) -> str:
    return re.sub(r"[^A-Z0-9]+", "_", name.upper())[:max_len].rstrip("_")


# ––– Main Ingestor ––––––––––––––––––––––––––––––––––––––––––––
class FundamentalsIngestor:
    def __init__(self) -> None:
        self.settings   = Settings()
        self.logger     = get_logger(self.__class__.__name__)
        self.pause      = getattr(self.settings, "sec_throttle", PAUSE_SEC_DEFAULT)

        if self.settings.sec_email:
            set_identity(self.settings.sec_email)
        if self.settings.edgar_cache_dir:
            os.environ["EDGARTOOLS_DATA_DIR"] = str(self.settings.edgar_cache_dir)

    # ── DB helpers ────────────────────────────────────────────
    def _connect(self):
        return psycopg2.connect(
            database = self.settings.database_name,
            user     = self.settings.db_username,
            password = self.settings.password,
            host     = self.settings.host,
            port     = self.settings.port,
        )

    def _stock_map(self, cur) -> dict[str, int]:
        cur.execute("SELECT stock_key, symbol FROM dim_stock")
        return {sym: key for key, sym in cur.fetchall()}

    def _sync_metric_dim(self, cur, metric_names: Set[str]) -> dict[str, tuple[int, str]]:
        cur.execute("SELECT metric_key, metric_name, stmt_code FROM dim_fin_metric")
        mapping = {n: (k, s) for k, n, s in cur.fetchall()}

        missing = metric_names.difference(mapping)
        if missing:
            self.logger.info("Adding %d new metrics …", len(missing))
            cur.executemany(
                """
                INSERT INTO dim_fin_metric (metric_name, metric_code, stmt_code)
                VALUES (%s, %s, %s)
                """,
                [(m, _derive_code(m), "CAL") for m in sorted(missing)],
            )
            cur.connection.commit()
            cur.execute("SELECT metric_key, metric_name, stmt_code FROM dim_fin_metric")
            mapping = {n: (k, s) for k, n, s in cur.fetchall()}
        return mapping

    def _get_source_key(self, cur) -> int:
        cur.execute("SELECT source_key FROM dim_source WHERE source_name = 'EDGAR'")
        row = cur.fetchone()
        if row:
            return row[0]
        cur.execute(
            "INSERT INTO dim_source (source_name, version) VALUES ('EDGAR', '1') RETURNING source_key"
        )
        return cur.fetchone()[0]

    def _fetch_tickers(self, cur) -> List[str]:
        # Use consensus snapshot for the latest universe, ordered by consensus strength
        cur.execute("SELECT symbol FROM v_latest_screener_consensus ORDER BY consensus_score DESC")
        return [r[0] for r in cur.fetchall()]

    # ── EDGAR download ───────────────────────────────────────
   
    def _load_fundamentals(self, tickers: List[str]) -> pd.DataFrame:
        frames: list[pd.DataFrame] = []

        for tkr in tickers:
            try:
                # ▲ new helper (returns income + ratios already combined)
                snap   = retrieve_multi_year_data(
                    tkr,
                    n_years    = YEARS_BACK,
                    n_quarters = QUARTERS,
                    filing_type= "10-Q",          # ▲ make it explicit
                )
                inc_df = snap["quarterly_data"]
            except Exception as exc:
                self.logger.error("Analytics fetch failed for %s – %s", tkr, exc)
                continue
            finally:
                time.sleep(self.pause)

            if inc_df.empty:
                continue

            # original reshaping logic
            qdf = inc_df.T.reset_index().rename(columns={"index": "period_end"})
            qdf["report_date"]   = qdf["period_end"].map(parse_period_label)
            qdf["fiscal_year"]   = qdf["report_date"].dt.year
            qdf["fiscal_per"]    = "Q" + qdf["report_date"].dt.quarter.astype(str)
            qdf["ticker"]        = tkr
            qdf["restated_date"] = pd.NaT

            frames.append(qdf)

        return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()
    
    # ── Flatten & up‑sert ───────────────────────────────────
    def _prepare_records(
        self,
        df: pd.DataFrame,
        metric_map: dict[str, tuple[int, str]],
        stock_map: dict[str, int],
        source_key: int,
    ) -> list[tuple]:
        cutoff = datetime.today() - timedelta(days=YEARS_BACK * 365)
        df = df[df["report_date"] >= pd.Timestamp(cutoff)]

        id_vars = ["ticker", "report_date", "fiscal_year", "fiscal_per", "restated_date"]
        long_df = (
            df.melt(id_vars=id_vars, var_name="metric_name", value_name="metric_value")
              .dropna(subset=["metric_value"])
        )

        long_df["metric_key"] = long_df["metric_name"].map(lambda m: metric_map[m][0])
        long_df["stmt_code"]  = long_df["metric_name"].map(lambda m: metric_map[m][1])
        long_df["stock_key"]  = long_df["ticker"].map(stock_map)

        long_df = long_df.dropna(subset=["metric_key", "stock_key", "stmt_code"])

        if long_df.empty:
            return []

        long_df["date_key"]  = long_df["report_date"].dt.strftime("%Y%m%d").astype(int)
        long_df["restated"]  = long_df["restated_date"].notna()
        long_df["ttm_flag"]  = False

        return list(zip(
            long_df["date_key"],
            long_df["stock_key"],
            [source_key] * len(long_df),
            long_df["fiscal_year"].astype(int),
            long_df["fiscal_per"],
            long_df["stmt_code"],
            long_df["metric_key"].astype(int),
            long_df["metric_value"].astype(float),
            long_df["restated"],
            long_df["ttm_flag"],
        ))

    def _upsert_records(self, cur, recs: Iterable[tuple]):
        sql = """
        INSERT INTO fact_fin_fundamentals (
            date_key, stock_key, source_key,
            fiscal_year, fiscal_per,
            stmt_code, metric_key, metric_value,
            restated, ttm_flag
        ) VALUES %s
        ON CONFLICT (date_key, stock_key, stmt_code, metric_key)
        DO UPDATE SET
            metric_value = EXCLUDED.metric_value,
            restated     = EXCLUDED.restated,
            ttm_flag     = EXCLUDED.ttm_flag,
            fiscal_year  = EXCLUDED.fiscal_year,
            fiscal_per   = EXCLUDED.fiscal_per,
            source_key   = EXCLUDED.source_key,
            load_ts      = NOW();
        """
        execute_values(cur, sql, recs, page_size=10_000)

    # ── Top‑level orchestrator ───────────────────────────────
    def run(self):
        with self._connect() as conn, conn.cursor() as cur:
            tickers    = self._fetch_tickers(cur)
            if not tickers:
                self.logger.info("No tickers to process – exiting")
                return

            stock_map  = self._stock_map(cur)
            source_key = self._get_source_key(cur)

            for idx in range(0, len(tickers), CHUNK_SIZE):
                chunk = tickers[idx : idx + CHUNK_SIZE]
                df    = self._load_fundamentals(chunk)
                if df.empty:
                    continue

                metric_map = self._sync_metric_dim(
                    cur,
                    set(df.columns) - {
                        "ticker", "period_end", "report_date",
                        "fiscal_year", "fiscal_per", "restated_date",
                    },
                )

                recs = self._prepare_records(df, metric_map, stock_map, source_key)
                if recs:
                    self._upsert_records(cur, recs)
                    conn.commit()
                    self.logger.info(
                        "Upserted %d facts for chunk %d / %d",
                        len(recs), idx // CHUNK_SIZE + 1,
                        -(-len(tickers) // CHUNK_SIZE)
                    )

        self.logger.info("✅ Fundamental ingestion complete")


if __name__ == "__main__":
    FundamentalsIngestor().run()
