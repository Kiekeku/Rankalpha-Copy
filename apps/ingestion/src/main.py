import os
import glob
from pathlib import Path
from datetime import datetime, timedelta

import psycopg2
import yfinance as yf
import pandas as pd

from apps.common.src.logging import get_logger
from apps.common.src.settings import Settings

def main():
    """Ingest historical prices into Parquet files under /data/prices.

    Behavior:
    - If a Parquet for a symbol already exists in /data/prices, skip downloading via yfinance.
    - Otherwise, fetch with yfinance and write `<SYMBOL>.parquet`.
    - Symbols come from `v_latest_screener_values`.
    """
    output_dir = "/data/prices"
    os.makedirs(output_dir, exist_ok=True)

    settings = Settings()
    logger = get_logger(__name__)
    logger.info("Starting ingestion")

    # Collect existing parquet files to avoid redundant downloads
    existing = set(
        Path(p).stem.upper() for p in glob.glob(os.path.join(output_dir, "*.parquet"))
    )
    logger.info(f"Found {len(existing)} existing parquet files in {output_dir}")

    # Connect to DB and read symbols
    conn = psycopg2.connect(
        database=settings.database_name,
        user=settings.db_username,
        password=settings.password,
        host=settings.host,
        port=settings.port,
    )
    cur = conn.cursor()
    # Ensure delisted-style tickers are marked inactive (idempotent)
    try:
        cur.execute("UPDATE dim_stock SET is_active = FALSE WHERE symbol ~ '-[0-9]{6}$' AND is_active = TRUE")
        conn.commit()
    except Exception:
        conn.rollback()
    # Prefer consensus view but only active stocks
    cur.execute(
        """
        SELECT v.symbol
        FROM v_latest_screener_consensus v
        JOIN dim_stock ds ON ds.symbol = v.symbol
        WHERE ds.is_active IS TRUE
        ORDER BY v.consensus_score DESC
        """
    )
    rows = cur.fetchall()

    total = 0
    skipped = 0
    downloaded = 0
    updated = 0

    def fetch_stock_key(symbol: str) -> int | None:
        c = conn.cursor()
        try:
            c.execute("SELECT stock_key FROM dim_stock WHERE symbol = %s AND is_active IS TRUE", (symbol,))
            r = c.fetchone()
            return int(r[0]) if r else None
        finally:
            c.close()

    def upsert_technical(date_key: int, stock_key: int, code: str, value: float) -> None:
        c = conn.cursor()
        try:
            c.execute(
                """
                INSERT INTO rankalpha.fact_technical_indicator (date_key, stock_key, indicator_code, value)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (date_key, stock_key, indicator_code)
                DO UPDATE SET value=EXCLUDED.value, load_ts=now()
                """,
                (date_key, stock_key, code.upper(), float(value))
            )
        finally:
            c.close()

    # Helper: use US/Eastern market "today" as exclusive end-date to avoid future days
    def _market_end_str() -> str:
        now_et = pd.Timestamp.now(tz="America/New_York")
        # yfinance treats 'end' as exclusive; using market midnight today excludes future dates
        return now_et.normalize().strftime('%Y-%m-%d')

    def download_prices(symbol: str, start_date: str | None = None) -> pd.DataFrame:
        """Download daily prices with an explicit end date of US/Eastern 'today'
        (exclusive) to avoid requesting future dates.
        """
        kwargs = dict(auto_adjust=False, progress=False)
        if start_date:
            return yf.download(symbol, start=start_date, end=_market_end_str(), **kwargs)
        else:
            return yf.download(symbol, end=_market_end_str(), **kwargs)

    for row in rows:
        symbol = str(row[0]).upper()
        total += 1

        dest_path = os.path.join(output_dir, f"{symbol}.parquet")
        file_exists = symbol in existing and os.path.exists(dest_path)

        if not file_exists:
            try:
                df = download_prices(symbol, start_date="2024-01-01")
                if df is None or df.empty:
                    logger.warning(f"No data returned by yfinance for {symbol}; skipping.")
                    continue
                df.to_parquet(dest_path, engine="pyarrow")
                downloaded += 1
                logger.info(f"Wrote {dest_path}")
            except Exception as e:
                logger.error(f"Failed to ingest {symbol}: {e}")
                continue
        else:
            skipped += 1
            logger.info(f"Parquet exists for {symbol}, skipping download.")

            # Check freshness and update incrementally if newer data exists (handles weekends/holidays)
            try:
                pdf_existing = pd.read_parquet(dest_path, engine="pyarrow")
                if pdf_existing is not None and not pdf_existing.empty:
                    # normalize index to DatetimeIndex
                    if not isinstance(pdf_existing.index, pd.DatetimeIndex):
                        if 'Date' in pdf_existing.columns:
                            pdf_existing.set_index(pd.to_datetime(pdf_existing['Date']), inplace=True)
                        else:
                            pdf_existing.index = pd.to_datetime(pdf_existing.index)
                    last_dt = pdf_existing.index[-1].normalize()
                    start_dt = last_dt + pd.Timedelta(days=1)
                    # Only fetch if start is strictly before market end bound (US/Eastern today at 00:00)
                    end_bound = pd.Timestamp.now(tz="America/New_York").normalize()
                    if start_dt.tz_localize(None) < end_bound.tz_localize(None):
                        df_new = download_prices(symbol, start_date=start_dt.strftime('%Y-%m-%d'))
                        if df_new is not None and not df_new.empty:
                            # Align columns and append
                            try:
                                combined = pd.concat([pdf_existing, df_new])
                                combined = combined[~combined.index.duplicated(keep='last')].sort_index()
                                combined.to_parquet(dest_path, engine="pyarrow")
                                updated += 1
                                logger.info(f"Updated {symbol} parquet with {len(df_new)} new rows")
                            except Exception as e:
                                logger.warning(f"Failed to append update for {symbol}: {e}")
                    else:
                        logger.info(
                            f"{symbol}: up-to-date (next start {start_dt.date()} >= market end {end_bound.date()})"
                        )
            except Exception as e:
                logger.warning(f"Freshness check failed for {symbol}: {e}")

        # Compute technicals from parquet for both fresh and existing files
        try:
            pdf = pd.read_parquet(dest_path, engine="pyarrow")
            if pdf is None or pdf.empty:
                logger.warning(f"Empty dataframe for {symbol} at {dest_path}; skipping technicals")
                continue
            if not isinstance(pdf.index, pd.DatetimeIndex):
                # best-effort normalize index
                if 'Date' in pdf.columns:
                    pdf.set_index(pd.to_datetime(pdf['Date']), inplace=True)
                else:
                    pdf.index = pd.to_datetime(pdf.index)
            date_key = int(pdf.index[-1].date().strftime("%Y%m%d"))
            stock_key = fetch_stock_key(symbol)
            if not stock_key:
                logger.warning(f"Stock {symbol} not found in dim_stock; skipping technicals")
                continue
            from apps.common.src.technicals import compute_technicals  # local import to avoid issues
            techs = compute_technicals(pdf)
            for code, val in techs.items():
                if val is None or pd.isna(val):
                    continue
                upsert_technical(date_key, stock_key, code, float(val))
            conn.commit()
        except Exception as e:
            logger.error(f"Failed computing technicals for {symbol}: {e}")
            conn.rollback()

    cur.close()
    conn.close()
    logger.info(
        f"Ingestion completed. total={total} downloaded={downloaded} updated={updated} skipped_existing={skipped}"
    )

if __name__ == "__main__":
    main()
