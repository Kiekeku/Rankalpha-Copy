import os
import glob
import pandas as pd
import psycopg2
from psycopg2 import errors as pg_errors
from scipy.stats import linregress


from apps.common.src.logging import get_logger
from apps.common.src.settings import Settings

SOURCE_KEY = 1

SCORE_TYPES = {
    "SMA_200": "SMA 200",
    "LINREG_200": "linear regression 200",
    "LINREG_90": "linear regression 90",
    "LINREG_50": "linear regression 50",
    "LINREG_30": "linear regression 30",
}

def _round2(value) -> float | None:
    """Round to 2 decimals, tolerating pandas/numpy scalars or 1‑elem Series.
    Returns None if value cannot be coerced to a scalar float or is NaN.
    """
    if value is None:
        return None
    # Reduce common pandas wrappers to a scalar
    try:
        # pandas/numpy scalar
        if hasattr(value, "item") and not isinstance(value, (pd.Series, pd.DataFrame)):
            value = value.item()
        # 1-element Series/DataFrame -> take last
        if isinstance(value, pd.Series):
            if value.empty:
                return None
            value = value.iloc[-1]
        if isinstance(value, pd.DataFrame):
            if value.empty:
                return None
            # take last cell
            value = value.iloc[-1].iloc[-1]
        v = float(value)
    except Exception:
        return None
    if pd.isna(v):
        return None
    return float(f"{v:.2f}")

def sma200_raw(df: pd.DataFrame) -> float | None:
    """Return 200-day simple moving average (raw price), rounded to 2 decimals."""
    if df.shape[0] < 200:
        return None
    close = df["Close"].astype(float)
    sma200 = close.rolling(200).mean().iloc[-1]
    return _round2(sma200)

def linreg_slope_raw(df: pd.DataFrame, window: int) -> float | None:
    """Return linear regression slope (price units per day), rounded to 2 decimals."""
    if df.shape[0] < window:
        return None
    seg = df.tail(window)
    y = seg["Close"].astype(float).values.ravel()
    x = range(len(y))
    valid = ~pd.isna(y)
    y = y[valid]
    x = [i for i, v in zip(x, valid) if v]
    if len(y) < 2:
        return None
    slope, _, _, _, _ = linregress(x, y)
    return _round2(slope)

def get_latest_date_key(df):
    last_date = df.index[-1].date()
    return int(last_date.strftime("%Y%m%d"))

def fetch_stock_key(cursor, ticker):
    cursor.execute("SELECT stock_key FROM dim_stock WHERE symbol = %s AND is_active IS TRUE", (ticker,))
    result = cursor.fetchone()
    return result[0] if result else None

def fetch_score_type_keys(cursor):
    cursor.execute("SELECT score_type_key, score_type_name FROM dim_score_type")
    return {name.lower(): key for key, name in cursor.fetchall()}

def insert_score(cursor, date_key, stock_key, score_type_key, value):
    cursor.execute(
        """
        INSERT INTO fact_score_history (
            date_key, stock_key, source_key, score_type_key, score
        ) VALUES (%s, %s, %s, %s, %s)
        """,
        (date_key, stock_key, SOURCE_KEY, score_type_key, value)
    )


def main():
    input_dir = "/data/prices"
    parquet_files = glob.glob(os.path.join(input_dir, "*.parquet"))

    settings = Settings()
    logger = get_logger(__name__)
    logger.info("Starting scoring")

    conn = psycopg2.connect(
        database=settings.database_name,
        user=settings.db_username,
        password=settings.password,
        host=settings.host,
        port=settings.port,
    )
    cursor = conn.cursor()

    score_type_map = fetch_score_type_keys(cursor)


    for file in parquet_files:
        df = pd.read_parquet(file, engine="pyarrow")
        ticker = os.path.splitext(os.path.basename(file))[0]

        date_key = get_latest_date_key(df)
        stock_key = fetch_stock_key(cursor, ticker)

        if stock_key is None:
            print(f"Ticker {ticker} not found in dim_stock.")
            continue

        scores = {
            "SMA_200": sma200_raw(df),
            "LINREG_200": linreg_slope_raw(df, 200),
            "LINREG_90": linreg_slope_raw(df, 90),
            "LINREG_50": linreg_slope_raw(df, 50),
            "LINREG_30": linreg_slope_raw(df, 30),
        }

        for score_label, value in scores.items():
            if value is None:
                continue
            score_name = SCORE_TYPES[score_label].lower()
            score_type_key = score_type_map.get(score_name)
            if score_type_key is None:
                print(f"Score type '{score_name}' not found in dim_score_type.")
                continue
            try:
                insert_score(cursor, date_key, stock_key, score_type_key, float(_round2(value)))
            except pg_errors.NumericValueOutOfRange as e:
                print(f"Insert skipped for {ticker} {score_label}: value out of NUMERIC(5,2) range -> {value}")
                continue
            except Exception as e:
                print(f"Insert skipped for {ticker} {score_label}: {e}")

        # Technical indicators are now computed during ingestion.
        # Scorer only writes momentum/linear-regression style scores to fact_score_history.

    conn.commit()
    cursor.close()
    conn.close()
    logger.info("Scoring completed")


if __name__ == "__main__":
    main()
