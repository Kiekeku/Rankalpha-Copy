import sys
from pathlib import Path

import pandas as pd

# add scorer src to path
ROOT = Path(__file__).resolve().parents[2]
SCORER_SRC = ROOT / "apps" / "scorer" / "src"
sys.path.insert(0, str(SCORER_SRC))

from main import lin_reg, sma_200, get_latest_date_key


def test_lin_reg():
    df = pd.DataFrame({"Close": range(10)})
    slope = lin_reg(df)
    assert slope > 0


def test_sma_200():
    df = pd.DataFrame({"Close": range(1, 201)})
    sma = sma_200(df)
    assert abs(sma - 100.5) < 1e-6


def test_get_latest_date_key():
    dates = pd.date_range("2024-01-01", periods=3)
    df = pd.DataFrame({"Close": [1, 2, 3]}, index=dates)
    key = get_latest_date_key(df)
    assert key == 20240103
