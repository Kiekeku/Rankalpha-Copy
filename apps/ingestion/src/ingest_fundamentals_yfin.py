"""
Grab the same statements from Yahoo! Finance so you can
compare coverage, lags and rounding conventions.

Prereqs:
    pip install  yfinance  pandas  --upgrade
"""
import pandas as pd
import yfinance as yf

TICKERS = ["MSFT", "META", "BAC", "GM", "PLTR"]

for tkr in TICKERS:
    tk = yf.Ticker(tkr)

    # yfinance returns separate DataFrames – pull them all
    dfs = {
        "income"   : tk.quarterly_financials,        # Income Statement
        "balance"  : tk.quarterly_balance_sheet,     # Balance Sheet
        "cashflow" : tk.quarterly_cashflow           # Cash‑flow Statement
        # add tk.quarterly_earnings if you like
    }                                                # (attributes listed in the official quick‑start) :contentReference[oaicite:1]{index=1}

    # Convert each to the same orientation as fundamental_data (dates as index)
    pieces = []
    for name, df in dfs.items():
        if df.empty:                                 # not all tickers have all statements
            continue
        df = df.T                                    # transpose → index = period end‑date
        df["statement"] = name                       # keep provenance
        pieces.append(df)

    combined = pd.concat(pieces).sort_index()
    combined.to_csv(f"{tkr}_yfinance_quarterly.csv")
    print(f"✅ {tkr:<5}  →  {combined.shape[0]:>3} rows  |  {tkr}_yfinance_quarterly.csv")
