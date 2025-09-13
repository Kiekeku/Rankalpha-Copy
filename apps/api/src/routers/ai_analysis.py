from __future__ import annotations

from typing import List, Optional, Dict, Any
from datetime import date, datetime
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import select, and_, desc, asc, func
from pydantic import BaseModel, Field

from ..database import get_db
from apps.common.src.models import VwAiAnalysisFull, DimStock


class AiAnalysisItem(BaseModel):
    analysis_id: UUID
    as_of_date: date
    symbol: str
    company_name: Optional[str] = None
    asset_type: Optional[str] = None
    source_name: Optional[str] = None

    market_cap_usd: Optional[float] = None
    revenue_cagr_3y_pct: Optional[float] = None

    gross_margin_trend: Optional[str] = None
    net_margin_trend: Optional[str] = None
    free_cash_flow_trend: Optional[str] = None
    insider_activity: Optional[str] = None

    beta_sp500: Optional[float] = None
    rate_sensitivity_bps: Optional[float] = None
    fx_sensitivity: Optional[str] = None
    commodity_exposure: Optional[str] = None

    news_sentiment_30d: Optional[float] = None
    social_sentiment_7d: Optional[float] = None
    options_skew_30d: Optional[float] = None
    short_interest_pct_float: Optional[float] = None
    employee_glassdoor_score: Optional[float] = None
    headline_buzz_score: Optional[str] = None
    commentary: Optional[str] = None

    overall_rating: Optional[str] = None
    confidence: Optional[str] = None
    recommendation_timeframe: Optional[str] = None

    pe_forward: Optional[float] = None
    ev_ebitda_forward: Optional[float] = None
    pe_percentile_in_sector: Optional[float] = None

    value_score: Optional[float] = None
    quality_score: Optional[float] = None
    momentum_score: Optional[float] = None
    low_vol_score: Optional[float] = None

    bull_price_target: Optional[float] = None
    bull_probability_pct: Optional[float] = None
    base_price_target: Optional[float] = None
    base_probability_pct: Optional[float] = None
    bear_price_target: Optional[float] = None
    bear_probability_pct: Optional[float] = None

    short_catalysts: Optional[List[Dict[str, Any]]] = None
    long_catalysts: Optional[List[Dict[str, Any]]] = None
    macro_risks: Optional[List[str]] = None
    headline_risks: Optional[List[str]] = None
    data_gaps: Optional[List[str]] = None
    peers: Optional[List[Dict[str, Any]]] = None


class AiAnalysisList(BaseModel):
    items: List[AiAnalysisItem]
    total_count: int
    page: int
    page_size: int


router = APIRouter(tags=["ai-analysis"], prefix="/api/v1/ai-analysis")


@router.get("", response_model=AiAnalysisList)
def list_ai_analyses(
    db: Session = Depends(get_db),
    symbol: Optional[str] = Query(None, description="Filter by symbol"),
    date_from: Optional[str] = Query(None, description="YYYY-MM-DD inclusive"),
    date_to: Optional[str] = Query(None, description="YYYY-MM-DD inclusive"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=500),
    sort_order: str = Query("desc", pattern="^(asc|desc)$")
):
    # Build filters once
    criteria = []
    if symbol:
        criteria.append(VwAiAnalysisFull.symbol == symbol.upper())
    if date_from:
        try:
            df = datetime.strptime(date_from, "%Y-%m-%d").date()
            criteria.append(VwAiAnalysisFull.as_of_date >= df)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date_from format. Use YYYY-MM-DD")
    if date_to:
        try:
            dt = datetime.strptime(date_to, "%Y-%m-%d").date()
            criteria.append(VwAiAnalysisFull.as_of_date <= dt)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date_to format. Use YYYY-MM-DD")

    # Main query with ordering and pagination
    q = (
        select(VwAiAnalysisFull)
        .join(DimStock, DimStock.symbol == VwAiAnalysisFull.symbol)
        .where(*(criteria + [DimStock.is_active.is_(True)]))
        .order_by(desc(VwAiAnalysisFull.as_of_date) if sort_order == "desc" else asc(VwAiAnalysisFull.as_of_date))
        .offset(skip)
        .limit(limit)
    )

    # Proper COUNT(*) with same filters (ignore ordering/pagination)
    total_count = db.execute(
        select(func.count())
        .select_from(VwAiAnalysisFull)
        .join(DimStock, DimStock.symbol == VwAiAnalysisFull.symbol)
        .where(*(criteria + [DimStock.is_active.is_(True)]))
    ).scalar() or 0

    rows = db.execute(q).scalars().all()
    items = [AiAnalysisItem(**_row_to_dict(r)) for r in rows]
    return AiAnalysisList(items=items, total_count=total_count, page=skip // limit + 1, page_size=limit)


@router.get("/{symbol}", response_model=AiAnalysisItem)
def get_latest_for_symbol(symbol: str, db: Session = Depends(get_db)):
    row = db.execute(
        select(VwAiAnalysisFull)
        .join(DimStock, DimStock.symbol == VwAiAnalysisFull.symbol)
        .where(VwAiAnalysisFull.symbol == symbol.upper(), DimStock.is_active.is_(True))
        .order_by(desc(VwAiAnalysisFull.as_of_date))
        .limit(1)
    ).scalar_one_or_none()
    if not row:
        raise HTTPException(status_code=404, detail=f"No AI analysis for {symbol}")
    return AiAnalysisItem(**_row_to_dict(row))


@router.get("/id/{analysis_id}", response_model=AiAnalysisItem)
def get_by_id(analysis_id: UUID, db: Session = Depends(get_db)):
    row = db.execute(
        select(VwAiAnalysisFull)
        .join(DimStock, DimStock.symbol == VwAiAnalysisFull.symbol)
        .where(VwAiAnalysisFull.analysis_id == analysis_id, DimStock.is_active.is_(True))
    ).scalar_one_or_none()
    if not row:
        raise HTTPException(status_code=404, detail="analysis_id not found")
    return AiAnalysisItem(**_row_to_dict(row))


def _row_to_dict(r: VwAiAnalysisFull) -> Dict[str, Any]:
    # Convert SQLAlchemy model instance to dict with primitives for JSON
    out = {
        "analysis_id": r.analysis_id,
        "as_of_date": r.as_of_date,
        "symbol": r.symbol,
        "company_name": r.company_name,
        "asset_type": r.asset_type,
        "source_name": r.source_name,
        "market_cap_usd": _to_float(r.market_cap_usd),
        "revenue_cagr_3y_pct": _to_float(r.revenue_cagr_3y_pct),
        "gross_margin_trend": r.gross_margin_trend,
        "net_margin_trend": r.net_margin_trend,
        "free_cash_flow_trend": r.free_cash_flow_trend,
        "insider_activity": r.insider_activity,
        "beta_sp500": _to_float(r.beta_sp500),
        "rate_sensitivity_bps": _to_float(r.rate_sensitivity_bps),
        "fx_sensitivity": r.fx_sensitivity,
        "commodity_exposure": r.commodity_exposure,
        "news_sentiment_30d": _to_float(r.news_sentiment_30d),
        "social_sentiment_7d": _to_float(r.social_sentiment_7d),
        "options_skew_30d": _to_float(r.options_skew_30d),
        "short_interest_pct_float": _to_float(r.short_interest_pct_float),
        "employee_glassdoor_score": _to_float(r.employee_glassdoor_score),
        "headline_buzz_score": r.headline_buzz_score,
        "commentary": r.commentary,
        "overall_rating": r.overall_rating,
        "confidence": r.confidence,
        "recommendation_timeframe": r.recommendation_timeframe,
        "pe_forward": _to_float(r.pe_forward),
        "ev_ebitda_forward": _to_float(r.ev_ebitda_forward),
        "pe_percentile_in_sector": _to_float(r.pe_percentile_in_sector),
        "value_score": _to_float(r.value_score),
        "quality_score": _to_float(r.quality_score),
        "momentum_score": _to_float(r.momentum_score),
        "low_vol_score": _to_float(r.low_vol_score),
        "bull_price_target": _to_float(r.bull_price_target),
        "bull_probability_pct": _to_float(r.bull_probability_pct),
        "base_price_target": _to_float(r.base_price_target),
        "base_probability_pct": _to_float(r.base_probability_pct),
        "bear_price_target": _to_float(r.bear_price_target),
        "bear_probability_pct": _to_float(r.bear_probability_pct),
        "short_catalysts": r.short_catalysts,
        "long_catalysts": r.long_catalysts,
        "macro_risks": r.macro_risks,
        "headline_risks": r.headline_risks,
        "data_gaps": r.data_gaps,
        "peers": r.peers,
    }
    return out


def _to_float(x):
    try:
        return float(x) if x is not None else None
    except Exception:
        return None
