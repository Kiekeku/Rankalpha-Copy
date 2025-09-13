from __future__ import annotations

from typing import List, Optional
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import select, desc, and_
from pydantic import BaseModel

from ..database import get_db
from apps.common.src.models import VLatestScreenerConsensus, DimStock


class ScreenerConsensusItem(BaseModel):
    as_of_date: date
    symbol: str
    company_name: Optional[str] = None
    sector: Optional[str] = None
    exchange: Optional[str] = None
    primary_source: Optional[str] = None
    primary_style: Optional[str] = None
    appearances: int
    styles_distinct: int
    sources_distinct: int
    rank_best: Optional[int] = None
    rank_avg: Optional[float] = None
    rank_median: Optional[float] = None
    min_style_rank_pct: Optional[float] = None
    consensus_score: Optional[float] = None


class ScreenerConsensusList(BaseModel):
    items: List[ScreenerConsensusItem]
    total_count: int
    page: int
    page_size: int


router = APIRouter(tags=["screener"], prefix="/api/v1/screener")


@router.get("/consensus", response_model=ScreenerConsensusList)
def list_screener_consensus(
    db: Session = Depends(get_db),
    symbol: Optional[str] = Query(None, description="Filter by symbol (exact)"),
    appearances_min: int = Query(0, ge=0),
    styles_min: int = Query(0, ge=0),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
):
    q = (
        select(VLatestScreenerConsensus)
        .join(DimStock, DimStock.symbol == VLatestScreenerConsensus.symbol)
        .where(DimStock.is_active.is_(True))
    )
    if symbol:
        q = q.where(VLatestScreenerConsensus.symbol == symbol.upper())
    if appearances_min > 0:
        q = q.where(VLatestScreenerConsensus.appearances >= appearances_min)
    if styles_min > 0:
        q = q.where(VLatestScreenerConsensus.styles_distinct >= styles_min)
    q = q.order_by(desc(VLatestScreenerConsensus.consensus_score))

    # Note: simple total_count; if large, consider COUNT(*) subquery
    total_count = db.execute(q).scalars().all()
    rows = total_count[skip : skip + limit]
    items = [
        ScreenerConsensusItem(
            as_of_date=row.full_date,
            symbol=row.symbol,
            company_name=row.company_name,
            sector=row.sector,
            exchange=row.exchange,
            primary_source=row.primary_source,
            primary_style=row.primary_style,
            appearances=row.appearances or 0,
            styles_distinct=row.styles_distinct or 0,
            sources_distinct=row.sources_distinct or 0,
            rank_best=row.rank_best,
            rank_avg=float(row.rank_avg) if row.rank_avg is not None else None,
            rank_median=float(row.rank_median) if row.rank_median is not None else None,
            min_style_rank_pct=float(row.min_style_rank_pct) if row.min_style_rank_pct is not None else None,
            consensus_score=float(row.consensus_score) if row.consensus_score is not None else None,
        )
        for row in rows
    ]
    return ScreenerConsensusList(
        items=items,
        total_count=len(total_count),
        page=(skip // limit) + 1,
        page_size=limit,
    )
