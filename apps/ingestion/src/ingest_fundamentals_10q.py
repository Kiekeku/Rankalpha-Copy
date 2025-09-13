"""
sec_edgar_to_yf.py  – FULL COPY-AND-PASTE VERSION
Maps SEC ‘company-facts’ JSON to yfinance-style quarterly data
and synthesises Q4 from 10-K / annual totals when the company
doesn’t file a separate Q4 frame.

Dependencies
------------
pip install fundamental_data pandas requests
"""
from __future__ import annotations

import collections
import re
import time
from typing import Dict, List

import numpy as np
import pandas as pd
import requests

# ╭──────────────────────────────────────────────────────────────────────────╮
#  1.  edgar_analytics helpers (giant synonym tables you pasted earlier)
# ╰──────────────────────────────────────────────────────────────────────────╯
from edgar_analytics.synonyms import SYNONYMS
from edgar_analytics.synonyms_utils import (
    normalize_text,
    flip_sign_if_negative_expense,
)

# ╭──────────────────────────────────────────────────────────────────────────╮
#  2.  yfinance-column → synonym-key mapping  (extend as you wish)
# ╰──────────────────────────────────────────────────────────────────────────╯
YF_TO_SYNONYMS_KEY: Dict[str, str] = {
    "Total Revenue": "revenue",
    "Cost Of Revenue": "cost_of_revenue",
    "Gross Profit": "gross_profit",
    "Research Development": "rnd_expenses",
    "SG&A": "operating_expenses",
    "Operating Income": "operating_income",
    "Other Income Expense": "other_income_expense",
    "Pretax Income": "income_before_taxes",
    "Tax Provision": "income_tax_expense",
    "Net Income": "net_income",
    "Basic EPS": "earnings_per_share_basic",
    "Diluted EPS": "earnings_per_share_diluted",
    "Basic Average Shares": "common_shares_outstanding",
    "Diluted Average Shares": "common_shares_outstanding",
    "Interest Expense": "interest_expense",
    "Capital Expenditures": "capital_expenditures",
}

EXPENSE_KEYS = {
    "cost_of_revenue",
    "operating_expenses",
    "rnd_expenses",
    "interest_expense",
    "depreciation_amortization",
}

# ╭──────────────────────────────────────────────────────────────────────────╮
#  3.  Helper – normalise GAAP tag for quick lookup
# ╰──────────────────────────────────────────────────────────────────────────╯
def _strip_prefix(tag: str) -> str:
    if ":" in tag:
        tag = tag.split(":", 1)[1]
    if tag.lower().startswith(("us-gaap_", "ifrs-full_")):
        tag = tag.split("_", 1)[1]
    return normalize_text(tag)


# ╭──────────────────────────────────────────────────────────────────────────╮
#  4.  Mapper: SEC → yfinance, + synth-Q4
# ╰──────────────────────────────────────────────────────────────────────────╯
def map_sec_to_yf(sec_df: pd.DataFrame, template_cols: List[str]) -> pd.DataFrame:
    """
    • Maps SEC tags to YF columns using edgar_analytics.SYNONYMS
    • Flips negative expenses
    • Fills missing Q4 using annual totals
    """
    out = pd.DataFrame(index=sec_df.index)
    norm_lookup = {_strip_prefix(c): c for c in sec_df.columns}

    # ---- 1) quarter-level merge ------------------------------------------
    for yf_col in template_cols:
        syn_key = YF_TO_SYNONYMS_KEY.get(yf_col)
        series = pd.Series(np.nan, index=sec_df.index)

        if syn_key:
            for cand in SYNONYMS.get(syn_key, []):
                tag_clean = _strip_prefix(cand)
                if tag_clean in norm_lookup:
                    series = series.combine_first(sec_df[norm_lookup[tag_clean]])

            if syn_key in EXPENSE_KEYS:
                series = series.apply(
                    lambda v: flip_sign_if_negative_expense(v, syn_key)
                    if pd.notna(v)
                    else v
                )

        out[yf_col] = series

    out = out[template_cols]  # preserve column order

       # ---- 2) synth Q4 from annual frames ----------------------------------
    if hasattr(sec_df, "AnnualTable"):       # sec_df is actually StockFundamentals
        annual_df = sec_df.AnnualTable
    else:
        annual_df = pd.DataFrame()

    if not annual_df.empty:
        for year_period, fy_row in annual_df.iterrows():
            year = year_period.year
            q_index = [pd.Period(f"{year}Q{i}", freq="Q") for i in (1, 2, 3)]
            q4_idx = pd.Period(f"{year}Q4", freq="Q")

            if q4_idx not in out.index:
                diff = fy_row - out.loc[out.index.intersection(q_index)].sum(skipna=True)
                out.loc[q4_idx] = diff

    # keep only quarters and sort chronologically
    out = out[out.index.to_series().apply(lambda p: p.freqstr.startswith("Q"))]
    out = out.sort_index()
    out = out.dropna(how="all")
    return out


# ╭──────────────────────────────────────────────────────────────────────────╮
#  5.  SEC download classes (minor tweak: capture annual frames)
# ╰──────────────────────────────────────────────────────────────────────────╯
class FundamentalData:
    def __init__(self, email: str):
        self.headers = {"User-Agent": email}
        self.company_data = self._fetch_company_index()

    def _fetch_company_index(self):
        url = "https://www.sec.gov/files/company_tickers.json"
        r = requests.get(url, headers=self.headers)
        r.raise_for_status()
        df = pd.DataFrame.from_dict(r.json(), orient="index")
        df["cik_str"] = df["cik_str"].astype(str).str.zfill(10)
        return df

    def get_cik(self, ticker):
        res = self.company_data[self.company_data.ticker == ticker.upper()]
        if res.empty:
            raise ValueError(f"{ticker} not in SEC index")
        return res.iloc[0].cik_str

    def get_fundamentals(self, ticker):
        try:
            cik = self.get_cik(ticker)
        except ValueError:
            return None
        url = f"https://data.sec.gov/api/xbrl/companyfacts/CIK{cik}.json"
        r = requests.get(url, headers=self.headers)
        if r.status_code != 200:
            print(f"⚠️  {ticker}: HTTP {r.status_code}")
            return None
        time.sleep(0.2)
        return StockFundamentals(r.json(), ticker)

    def get_bulk_fundamentals(self, tickers):
        out = {}
        for t in tickers:
            sf = self.get_fundamentals(t)
            if sf:
                out[t] = sf
            time.sleep(0.2)
        return out


class StockFundamentals:
    def __init__(self, data: dict, ticker: str):
        self.ticker = ticker
        self.raw_gaap = data["facts"]["us-gaap"]
        self._item_store = collections.defaultdict(list)
        self._parse_items()
        self.QuarterlyTable = self._build_quarterly_table()
    def _parse_items(self):
        """
        Collect rows with a clean 'period' object and a 'type':
        • type='Q' → 2024Q3
        • type='A' → 2023 (annual)
        """
        q_re = re.compile(r"(?P<yr>\d{4})Q(?P<q>[1-4])", re.I)
        y_re = re.compile(r"(?P<yr>\d{4})$", re.I)

        for tag, fact in self.raw_gaap.items():
            if "Deprecated" in str(fact.get("label", "")):
                continue
            unit_items = next(iter(fact["units"].values()), [])
            for it in unit_items:
                frame = (it.get("frame") or "").strip()
                if not frame:
                    continue

                m_q = q_re.search(frame)
                m_a = y_re.search(frame) if m_q is None else None

                if m_q:
                    p = pd.Period(f"{m_q.group('yr')}Q{m_q.group('q')}", freq="Q")
                    self._item_store[tag].append(
                        {"period": p, "value": it.get("val", np.nan), "type": "Q"}
                    )
                elif m_a:
                    p = pd.Period(m_a.group("yr"), freq="Y")
                    self._item_store[tag].append(
                        {"period": p, "value": it.get("val", np.nan), "type": "A"}
                    )


    def _build_quarterly_table(self):
        rows_q, rows_a = [], []
        for tag, items in self._item_store.items():
            for it in items:
                row = {"period": it["period"], "metric": tag, "value": it["value"]}
                (rows_q if it["type"] == "Q" else rows_a).append(row)

        # QUARTERS — safe because every Period has freq='Q'
        qdf = (
            pd.DataFrame(rows_q)
            .pivot_table(
                index="period",
                columns="metric",
                values="value",
                aggfunc="first",
                sort=False,      # <= important: no sort => no freq-mix compare
            )
        )

        # YEARS — same idea, stored separately
        adf = (
            pd.DataFrame(rows_a)
            .pivot_table(
                index="period",
                columns="metric",
                values="value",
                aggfunc="first",
                sort=False,
            )
        )

        self.AnnualTable = adf       #  ← keep for Q4 back-fill
        return qdf                   #  ← only quarters go downstream



# ╭──────────────────────────────────────────────────────────────────────────╮
#  6.  Main script
# ╰──────────────────────────────────────────────────────────────────────────╯
if __name__ == "__main__":
    UA_EMAIL = "your.email@company.com"
    TICKERS = ["MSFT", "META", "BAC"]

    # yfinance template columns taken from any existing CSV
    TEMPLATE_COLS = (
        pd.read_csv("BAC_yfinance_quarterly.csv", index_col=0).columns.tolist()
    )

    fd = FundamentalData(UA_EMAIL)
    fundamentals = fd.get_bulk_fundamentals(TICKERS)

    for tkr, obj in fundamentals.items():
        raw = obj.QuarterlyTable
        raw.to_csv(f"{tkr}_sec_quarterly.csv")

        mapped = map_sec_to_yf(raw, TEMPLATE_COLS)
        mapped.to_csv(f"{tkr}_sec_mapped_quarterly.csv")

        print(
            f"✅ {tkr:<5} | {raw.shape[0]} periods raw → "
            f"{mapped.shape[0]} quarters mapped (Q4 filled) | files saved."
        )
