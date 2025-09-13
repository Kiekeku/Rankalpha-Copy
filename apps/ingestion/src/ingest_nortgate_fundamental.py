import logging
from datetime import datetime
from typing import List

import norgatedata as nd
from sqlalchemy.orm import Session

from apps.common.src.crud import (
    get_engine,
    get_or_create_metric,
    get_or_create_stock,
    upsert_fundamental,
)

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s")

# Default list of fundamental fields. Adjust according to Norgate's documentation.
FUNDAMENTAL_FIELDS: List[str] = [
    "sharesoutstanding",
    "sharesfloat",
    # Add additional fields from Norgate's documentation as required
]





def ingest_fundamentals(watchlist: str) -> None:
    """Fetch fundamentals from Norgate and upsert them into the database."""
    logging.info("Fetching symbols for watchlist '%s'", watchlist)
    symbols = nd.watchlist_symbols(watchlist)
    if not symbols:
        logging.error("No symbols found for watchlist '%s'", watchlist)
        return

    engine = get_engine()
    with Session(engine) as session:
        for symbol in symbols:
            logging.info("Processing %s", symbol)
            stock_key = get_or_create_stock(session, symbol)

            for field in FUNDAMENTAL_FIELDS:
                try:
                    value, fdate = nd.fundamental(symbol, field)
                except Exception as exc:  # pragma: no cover - network
                    logging.error("Failed to fetch %s for %s: %s", field, symbol, exc)
                    continue

                if value is None or fdate is None:
                    continue

                if not isinstance(fdate, datetime):
                    fdate = datetime.fromisoformat(str(fdate))
                date_key = int(fdate.strftime("%Y%m%d"))

                metric_key = get_or_create_metric(session, field)
                upsert_fundamental(session, date_key, stock_key, metric_key, value)
        session.commit()


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Ingest Norgate fundamentals into the RankAlpha schema")
    parser.add_argument("watchlist", help="Name of the Norgate watchlist to import")
    args = parser.parse_args()

    ingest_fundamentals(args.watchlist)


if __name__ == "__main__":
    main()
