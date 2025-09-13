import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
paths = [
    ROOT / "apps" / "common" / "src",
    ROOT / "apps" / "ingestion" / "src",
    ROOT / "apps" / "scorer" / "src",
    ROOT / "apps" / "sentiment",
]
for p in paths:
    sys.path.insert(0, str(p))
