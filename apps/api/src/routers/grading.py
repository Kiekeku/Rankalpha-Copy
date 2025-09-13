from __future__ import annotations

from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta
from decimal import Decimal
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import select, func, and_, or_, desc, asc, text, case, literal_column, literal
from pydantic import BaseModel, Field

from ..database import get_db
from ..cache import make_key, get_json, set_json, invalidate_prefix
from apps.common.src.models import (
    DimStock, 
    FactScoreHistory,
    FactAiStockAnalysis,
    FactNewsSentiment,
    FactNewsArticles,
    DimScoreType,
    DimDate,
    FactAiFactorScore,
    DimStyle,
    VwScoreHistory,
    VLatestScreenerValues,
    FactSecurityPrice,
    FactAiHeadlineRisk,
    VwAiAnalysisFull,
    MvLatestGrades,
)
from ..settings import Settings


class StockGrade(BaseModel):
    symbol: str
    company_name: Optional[str] = None
    date: date
    momentum_score: Optional[float] = Field(None, description="Momentum score (0-100)")
    value_score: Optional[float] = Field(None, description="Value score (0-100)")
    sentiment_score: Optional[float] = Field(None, description="Sentiment score (0-100)")
    overall_grade: str = Field(..., description="Letter grade A-F")
    grade_explanation: str = Field(..., description="Explanation of the grade")
    confidence: str = Field("Medium", description="High/Medium/Low confidence")
    

class GradeLeaderboard(BaseModel):
    stocks: List[StockGrade]
    total_count: int
    page: int
    page_size: int
    

class AssetDetail(BaseModel):
    symbol: str
    company_name: Optional[str] = None
    sector: Optional[str] = None
    exchange: Optional[str] = None
    current_grade: StockGrade
    score_history: List[Dict[str, Any]]
    recent_news: List[Dict[str, Any]]
    ai_analysis: Optional[Dict[str, Any]] = None


router = APIRouter(tags=["grading"], prefix="/api/v1/grading")


def calculate_letter_grade(
    momentum_score: Optional[float],
    value_score: Optional[float],
    sentiment_score: Optional[float]
) -> tuple[str, str]:
    """
    Calculate letter grade based on scores.
    Returns (grade, explanation)
    """
    scores = []
    if momentum_score is not None:
        scores.append(momentum_score)
    if value_score is not None:
        scores.append(value_score)
    if sentiment_score is not None:
        scores.append(sentiment_score)
    
    if not scores:
        return "N/A", "Insufficient data for grading"
    
    avg_score = sum(scores) / len(scores)
    
    # Grade boundaries
    if avg_score >= 85:
        grade = "A"
        explanation = "Excellent across all metrics - strong momentum, good value, and positive sentiment"
    elif avg_score >= 70:
        grade = "B"
        explanation = "Good overall performance with solid fundamentals and market sentiment"
    elif avg_score >= 55:
        grade = "C"
        explanation = "Average performance - mixed signals across metrics"
    elif avg_score >= 40:
        grade = "D"
        explanation = "Below average - showing weakness in multiple areas"
    else:
        grade = "F"
        explanation = "Poor performance - significant concerns across metrics"
    
    # Add specific metric commentary
    details = []
    if momentum_score is not None:
        if momentum_score >= 70:
            details.append("strong price momentum")
        elif momentum_score <= 30:
            details.append("weak price momentum")
    
    if value_score is not None:
        if value_score >= 70:
            details.append("attractive valuation")
        elif value_score <= 30:
            details.append("expensive valuation")
    
    if sentiment_score is not None:
        if sentiment_score >= 70:
            details.append("positive market sentiment")
        elif sentiment_score <= 30:
            details.append("negative market sentiment")
    
    if details:
        explanation += f". Key factors: {', '.join(details)}."
    
    return grade, explanation


@router.get("/sectors", response_model=List[str])
def list_sectors(db: Session = Depends(get_db)) -> List[str]:
    """Return distinct active sectors sorted alphabetically."""
    rows = (
        db.execute(
            select(DimStock.sector)
            .where(DimStock.is_active.is_(True), DimStock.sector.isnot(None))
            .distinct()
            .order_by(DimStock.sector.asc())
        )
        .scalars()
        .all()
    )
    return [s for s in rows if s]


@router.get("/grades", response_model=GradeLeaderboard)
def get_stock_grades(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=200),
    min_grade: Optional[str] = Query(None, regex="^[A-F]$"),
    max_grade: Optional[str] = Query(None, regex="^[A-F]$"),
    sector: Optional[str] = None,
    sort_by: str = Query("grade", regex="^(grade|momentum|value|sentiment|symbol)$"),
    sort_order: str = Query("desc", regex="^(asc|desc)$")
):
    print(f"Fetching grades with skip={skip}, limit={limit}, min_grade={min_grade}, max_grade={max_grade}, sector={sector}, sort_by={sort_by}, sort_order={sort_order}")
    """
    Get stock grades with filtering and pagination, optimized to avoid N+1 queries.
    Computes momentum/value/sentiment in one SQL and sorts/paginates in the DB.
    """
    # Attempt cache first
    cache_settings = Settings()
    cache_ttl = int(cache_settings.cache_ttl_rankings or 300)
    cache_key = make_key(
        "grades",
        {
            "skip": skip,
            "limit": limit,
            "min_grade": min_grade or "",
            "max_grade": max_grade or "",
            "sector": sector or "",
            "sort_by": sort_by,
            "sort_order": sort_order,
        },
    )
    cached = get_json(cache_key)
    if cached:
        return cached

    # Resolve latest date + date_key once to enable partition pruning
    # Try fast path using materialized view if available
    try:
        grade_to_ord = {"A": 5, "B": 4, "C": 3, "D": 2, "F": 1}
        mv = MvLatestGrades
        criteria: list[Any] = []
        # sector filter
        if sector:
            criteria.append(mv.sector == sector)
        # grade filters
        if min_grade:
            criteria.append(mv.grade_order >= grade_to_ord[min_grade])
        if max_grade:
            criteria.append(mv.grade_order <= grade_to_ord[max_grade])

        # Sorting
        if sort_by == "grade":
            order_cols = [mv.grade_order.desc() if sort_order == "desc" else mv.grade_order.asc(), mv.symbol.asc()]
        elif sort_by == "momentum":
            order_cols = [mv.momentum_score.desc() if sort_order == "desc" else mv.momentum_score.asc(), mv.symbol.asc()]
        elif sort_by == "value":
            order_cols = [mv.value_score.desc() if sort_order == "desc" else mv.value_score.asc(), mv.symbol.asc()]
        elif sort_by == "sentiment":
            order_cols = [mv.sentiment_score.desc() if sort_order == "desc" else mv.sentiment_score.asc(), mv.symbol.asc()]
        else:
            order_cols = [mv.symbol.desc() if sort_order == "desc" else mv.symbol.asc()]

        sub = (
            select(
                mv.symbol,
                mv.company_name,
                mv.momentum_score,
                mv.value_score,
                mv.sentiment_score,
                mv.avg_score,
                mv.grade,
                mv.grade_order,
                mv.as_of_date,
                func.count().over().label("_total_count"),
            )
            .select_from(mv)
            .where(*criteria)
            .order_by(*order_cols)
            .offset(skip)
            .limit(limit)
        )
        rows = db.execute(sub).all()
        total_count = int(rows[0]._total_count) if rows else 0
        stocks: list[StockGrade] = []
        for r in rows:
            grade_str, expl = calculate_letter_grade(
                float(r.momentum_score) if r.momentum_score is not None else None,
                float(r.value_score) if r.value_score is not None else None,
                float(r.sentiment_score) if r.sentiment_score is not None else None,
            )
            stocks.append(
                StockGrade(
                    symbol=r.symbol,
                    company_name=r.company_name,
                    date=r.as_of_date,
                    momentum_score=float(r.momentum_score) if r.momentum_score is not None else None,
                    value_score=float(r.value_score) if r.value_score is not None else None,
                    sentiment_score=float(r.sentiment_score) if r.sentiment_score is not None else None,
                    overall_grade=grade_str,
                    grade_explanation=expl,
                    confidence="Medium" if r.momentum_score is not None else "Low",
                )
            )
        result = GradeLeaderboard(
            stocks=stocks,
            total_count=total_count,
            page=skip // limit + 1,
            page_size=limit,
        )
        payload = {
            "stocks": [s.model_dump() for s in result.stocks],
            "total_count": result.total_count,
            "page": result.page,
            "page_size": result.page_size,
        }
        set_json(cache_key, payload, ttl_secs=cache_ttl)
        return payload
    except Exception:
        # Fall back to on-the-fly computation
        pass

    latest = db.execute(
        select(DimDate.date_key, DimDate.full_date)
        .join(FactScoreHistory, FactScoreHistory.date_key == DimDate.date_key)
        .order_by(DimDate.full_date.desc())
        .limit(1)
    ).one_or_none()
    if not latest:
        return GradeLeaderboard(stocks=[], total_count=0, page=1, page_size=limit)
    latest_date_key, latest_date = latest

    if not latest_date:
        return GradeLeaderboard(stocks=[], total_count=0, page=1, page_size=limit)

    # Identify momentum score_type_key to hit partitioned fact table directly (faster than view)
    linreg200 = db.execute(
        select(DimScoreType.score_type_key).where(DimScoreType.score_type_name == "linear regression 200")
    ).scalar_one_or_none()

    # Subquery: momentum (raw slope) at latest date from fact table (partition-pruned)
    if linreg200 is not None:
        # Aggregate to one row per symbol to avoid duplicates from multiple sources
        momentum_base = (
            select(
                DimStock.symbol.label("m_symbol"),
                func.max(FactScoreHistory.score).label("momentum_raw"),
            )
            .join(FactScoreHistory, FactScoreHistory.stock_key == DimStock.stock_key)
            .where(
                and_(
                    FactScoreHistory.date_key == latest_date_key,
                    FactScoreHistory.score_type_key == linreg200,
                )
            )
            .group_by(DimStock.symbol)
        )
    else:
        # Fallback to the view if score_type lookup failed (should be rare)
        momentum_base = (
            select(
                VwScoreHistory.symbol.label("m_symbol"),
                func.max(VwScoreHistory.score).label("momentum_raw"),
            )
            .where(
                and_(
                    VwScoreHistory.score_type_name == "linear regression 200",
                    VwScoreHistory.as_of_date == latest_date,
                )
            )
            .group_by(VwScoreHistory.symbol)
        )

    momentum_sq = momentum_base.subquery()

    # Percentiles for winsorization across today's momentum distribution (deduped per symbol)
    p05 = (
        select(func.percentile_cont(0.05).within_group(momentum_sq.c.momentum_raw))
        .select_from(momentum_sq)
        .scalar_subquery()
    )
    p95 = (
        select(func.percentile_cont(0.95).within_group(momentum_sq.c.momentum_raw))
        .select_from(momentum_sq)
        .scalar_subquery()
    )

    # Subquery: AI analysis (value score, sentiment proxy) at latest date – one row per symbol
    ai_sq = (
        select(
            VwAiAnalysisFull.symbol.label("a_symbol"),
            func.max(VwAiAnalysisFull.value_score).label("value_score"),
            func.max(VwAiAnalysisFull.news_sentiment_30d).label("news_sentiment_30d"),
        )
        .where(VwAiAnalysisFull.as_of_date == latest_date)
        .group_by(VwAiAnalysisFull.symbol)
        .subquery()
    )

    # Subquery: 30d news sentiment fallback (avg by stock)
    thirty_days_ago = latest_date - timedelta(days=30)
    news_sq = (
        select(
            FactNewsArticles.stock_key.label("n_stock_key"),
            func.avg(FactNewsSentiment.sentiment_score).label("news_avg"),
        )
        .join(FactNewsSentiment, FactNewsSentiment.article_id == FactNewsArticles.article_id)
        .join(DimDate, DimDate.date_key == FactNewsArticles.article_date)
        .where(DimDate.full_date >= thirty_days_ago)
        .group_by(FactNewsArticles.stock_key)
        .subquery()
    )

    # Expressions for computed scores
    # NOTE: Momentum normalization matches prior behavior: (raw + 1) * 50
    # Normalize raw slope to 0–100 using winsorized [p05, p95] and clamp
    # If momentum view had duplicates, aggregate to one per symbol first
    m_sq = (
        select(momentum_sq.c.m_symbol, func.max(momentum_sq.c.momentum_raw).label("mom_raw"))
        .group_by(momentum_sq.c.m_symbol)
        .subquery()
    )
    momentum_score_expr = case(
        (
            m_sq.c.m_symbol.isnot(None),
            func.least(
                100.0,
                func.greatest(
                    0.0,
                    ((m_sq.c.mom_raw - p05) / func.nullif(p95 - p05, 0.0)) * 100.0,
                ),
            ),
        ),
        else_=None,
    ).label("momentum_score")

    sentiment_0_100_expr = (
        # Prefer AI sentiment; else fallback to 30d news avg
        (func.coalesce(ai_sq.c.news_sentiment_30d, news_sq.c.news_avg) + 1.0) * 50.0
    ).label("sentiment_score")

    # Build main query
    base = (
        select(
            DimStock.symbol.label("symbol"),
            DimStock.company_name.label("company_name"),
            momentum_score_expr,
            ai_sq.c.value_score.label("value_score"),
            sentiment_0_100_expr,
        )
        .select_from(DimStock)
        .join(m_sq, m_sq.c.m_symbol == DimStock.symbol, isouter=True)
        .join(ai_sq, ai_sq.c.a_symbol == DimStock.symbol, isouter=True)
        .join(news_sq, news_sq.c.n_stock_key == DimStock.stock_key, isouter=True)
        .where(DimStock.is_active.is_(True))
    )

    if sector:
        base = base.where(DimStock.sector == sector)

    # Compute average and grade in SQL
    base_sq = base.subquery()
    m = base_sq.c.momentum_score
    v = base_sq.c.value_score
    s = base_sq.c.sentiment_score
    non_null_count = (
        (case((m.isnot(None), 1), else_=0))
        + (case((v.isnot(None), 1), else_=0))
        + (case((s.isnot(None), 1), else_=0))
    ).label("score_count")
    avg_score = (
        (func.coalesce(m, 0) + func.coalesce(v, 0) + func.coalesce(s, 0))
        / func.nullif(non_null_count, 0)
    ).label("avg_score")

    grade_case = case(
        (avg_score >= 85, literal("A")),
        (avg_score >= 70, literal("B")),
        (avg_score >= 55, literal("C")),
        (avg_score >= 40, literal("D")),
        (avg_score.isnot(None), literal("F")),
        else_=literal("N/A"),
    ).label("grade")

    # Grade ordering helper for sorting/filtering
    grade_order = case(
        (grade_case == "A", 5),
        (grade_case == "B", 4),
        (grade_case == "C", 3),
        (grade_case == "D", 2),
        (grade_case == "F", 1),
        else_=0,
    ).label("grade_order")

    query = select(
        base_sq.c.symbol,
        base_sq.c.company_name,
        m.label("momentum_score"),
        v.label("value_score"),
        s.label("sentiment_score"),
        avg_score,
        grade_case.label("grade"),
        grade_order,
    ).select_from(base_sq)

    # Apply grade filters (map letters to grade_order)
    grade_to_ord = {"A": 5, "B": 4, "C": 3, "D": 2, "F": 1}
    # min_grade = at least this grade (A best → higher order)
    if min_grade:
        query = query.where(grade_order >= grade_to_ord[min_grade])
    # max_grade = at most this grade (worse or equal)
    if max_grade:
        query = query.where(grade_order <= grade_to_ord[max_grade])

    # Sorting
    if sort_by == "grade":
        order_expr = grade_order.desc() if sort_order == "desc" else grade_order.asc()
    elif sort_by == "momentum":
        order_expr = (m.desc() if sort_order == "desc" else m.asc())
    elif sort_by == "value":
        order_expr = (v.desc() if sort_order == "desc" else v.asc())
    elif sort_by == "sentiment":
        order_expr = (s.desc() if sort_order == "desc" else s.asc())
    else:
        order_expr = (base_sq.c.symbol.desc() if sort_order == "desc" else base_sq.c.symbol.asc())

    # One-shot fetch with total_count as a window function to avoid an extra round-trip
    # Build outer select with ordering applied at the top level (ORDER BY inside subqueries is not guaranteed)
    filtered = query.subquery()
    order_cols = []
    if sort_by == "grade":
        order_cols.append(filtered.c.grade_order.desc() if sort_order == "desc" else filtered.c.grade_order.asc())
    elif sort_by == "momentum":
        order_cols.append(filtered.c.momentum_score.desc() if sort_order == "desc" else filtered.c.momentum_score.asc())
    elif sort_by == "value":
        order_cols.append(filtered.c.value_score.desc() if sort_order == "desc" else filtered.c.value_score.asc())
    elif sort_by == "sentiment":
        order_cols.append(filtered.c.sentiment_score.desc() if sort_order == "desc" else filtered.c.sentiment_score.asc())
    else:
        order_cols.append(filtered.c.symbol.desc() if sort_order == "desc" else filtered.c.symbol.asc())
    order_cols.append(filtered.c.symbol.asc())  # stable tie-breaker

    outer = select(
        filtered.c.symbol,
        filtered.c.company_name,
        filtered.c.momentum_score,
        filtered.c.value_score,
        filtered.c.sentiment_score,
        filtered.c.avg_score,
        filtered.c.grade,
        filtered.c.grade_order,
        func.count().over().label("_total_count"),
    ).select_from(filtered).order_by(*order_cols).offset(skip).limit(limit)

    rows = db.execute(outer).all()
    total_count = int(rows[0]._total_count) if rows else 0

    stocks: list[StockGrade] = []
    for r in rows:
        # Rebuild explanation to mirror previous behavior
        grade_str, expl = calculate_letter_grade(
            float(r.momentum_score) if r.momentum_score is not None else None,
            float(r.value_score) if r.value_score is not None else None,
            float(r.sentiment_score) if r.sentiment_score is not None else None,
        )
        stocks.append(
            StockGrade(
                symbol=r.symbol,
                company_name=r.company_name,
                date=latest_date,
                momentum_score=float(r.momentum_score) if r.momentum_score is not None else None,
                value_score=float(r.value_score) if r.value_score is not None else None,
                sentiment_score=float(r.sentiment_score) if r.sentiment_score is not None else None,
                overall_grade=grade_str,
                grade_explanation=expl,
                confidence="Medium" if r.momentum_score is not None else "Low",
            )
        )

    result = GradeLeaderboard(
        stocks=stocks,
        total_count=total_count,
        page=skip // limit + 1,
        page_size=limit,
    )
    # Cache serialized payload
    payload = {
        "stocks": [s.model_dump() for s in result.stocks],
        "total_count": result.total_count,
        "page": result.page,
        "page_size": result.page_size,
    }
    set_json(cache_key, payload, ttl_secs=cache_ttl)
    return payload


@router.get("/grades/{symbol}", response_model=StockGrade)
def get_stock_grade(symbol: str, db: Session = Depends(get_db)):
    """
    Get grade for a specific stock.
    """
    stock = db.execute(
        select(DimStock).where(func.upper(DimStock.symbol) == symbol.upper(), DimStock.is_active.is_(True))
    ).scalar_one_or_none()
    
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found")
    
    # Cache lookup
    cache_settings = Settings()
    grade_ttl = int((cache_settings.cache_ttl_stock_detail or 600))
    cache_key = make_key("grade", {"symbol": symbol.upper()})
    cached = get_json(cache_key)
    if cached:
        # Return as model for reuse within API
        return StockGrade(**cached)

    # Get latest date
    latest_date_result = db.execute(
        select(func.max(DimDate.full_date))
        .join(FactScoreHistory, FactScoreHistory.date_key == DimDate.date_key)
    ).scalar()
    
    if not latest_date_result:
        raise HTTPException(status_code=404, detail="No data available")
    
    # Get scores
    momentum_score = None
    value_score = None
    sentiment_score = None
    
    # Get momentum (raw slope) and winsorize to 0–100 using today's distribution
    momentum_result = db.execute(
        select(VwScoreHistory.score)
        .where(
            and_(
                VwScoreHistory.symbol == stock.symbol,
                VwScoreHistory.score_type_name == "linear regression 200",
                VwScoreHistory.as_of_date == latest_date_result,
            )
        )
        .limit(1)
    ).scalar()
    if momentum_result is not None:
        pcts = db.execute(
            select(
                func.percentile_cont(0.05).within_group(VwScoreHistory.score),
                func.percentile_cont(0.95).within_group(VwScoreHistory.score),
            )
            .where(
                and_(
                    VwScoreHistory.score_type_name == "linear regression 200",
                    VwScoreHistory.as_of_date == latest_date_result,
                )
            )
        ).one_or_none()
        if pcts and pcts[0] is not None and pcts[1] is not None and float(pcts[1]) != float(pcts[0]):
            p05, p95 = float(pcts[0]), float(pcts[1])
            momentum_score = max(0.0, min(100.0, (float(momentum_result) - p05) / (p95 - p05) * 100.0))
    
    # Get AI analysis via consolidated view (latest for the date)
    ai_view = db.execute(
        select(VwAiAnalysisFull)
        .where(
            and_(
                VwAiAnalysisFull.symbol == stock.symbol,
                VwAiAnalysisFull.as_of_date == latest_date_result,
            )
        )
        .limit(1)
    ).scalar_one_or_none()
    
    if ai_view:
        # Prefer value from AI factor scores in the view
        if ai_view.value_score is not None:
            value_score = float(ai_view.value_score)
        # Derive sentiment (0–100) from news_sentiment_30d if not set
        if sentiment_score is None and ai_view.news_sentiment_30d is not None:
            sentiment_score = (float(ai_view.news_sentiment_30d) + 1.0) * 50.0
    
    # Get news sentiment if not from AI
    if sentiment_score is None:
        # Calculate the date 30 days ago
        thirty_days_ago = latest_date_result - timedelta(days=30)
        
        sentiment_result = db.execute(
            select(func.avg(FactNewsSentiment.sentiment_score))
            .join(FactNewsArticles, FactNewsArticles.article_id == FactNewsSentiment.article_id)
            .join(DimDate, DimDate.date_key == FactNewsArticles.article_date)
            .where(
                and_(
                    FactNewsArticles.stock_key == stock.stock_key,
                    DimDate.full_date >= thirty_days_ago
                )
            )
        ).scalar()
        
        if sentiment_result:
            sentiment_score = float((sentiment_result + 1) * 50)
    
    grade, explanation = calculate_letter_grade(momentum_score, value_score, sentiment_score)
    
    # Add AI commentary if available
    if ai_view and getattr(ai_view, "commentary", None):
        explanation += f" AI Analysis: {ai_view.commentary}"
    
    grade_obj = StockGrade(
        symbol=stock.symbol,
        company_name=stock.company_name,
        date=latest_date_result,
        momentum_score=momentum_score,
        value_score=value_score,
        sentiment_score=sentiment_score,
        overall_grade=grade,
        grade_explanation=explanation,
        confidence="High" if ai_view else "Medium" if momentum_score else "Low"
    )
    # Populate cache for future calls
    set_json(cache_key, grade_obj.model_dump(), ttl_secs=grade_ttl)
    return grade_obj


@router.get("/asset/{symbol}", response_model=AssetDetail)
def get_asset_detail(
    symbol: str,
    db: Session = Depends(get_db),
    days: int = Query(90, ge=1, le=365)
):
    """
    Get detailed information for a specific asset including history.
    """
    stock = db.execute(
        select(DimStock).where(func.upper(DimStock.symbol) == symbol.upper(), DimStock.is_active.is_(True))
    ).scalar_one_or_none()
    
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found")
    
    # Cache: asset detail by symbol and days
    cache_settings = Settings()
    asset_ttl = int((cache_settings.cache_ttl_stock_detail or 600))
    cache_key = make_key("asset", {"symbol": symbol.upper(), "days": days})
    cached = get_json(cache_key)
    if cached:
        return cached

    # Get current grade (includes its own cache)
    current_grade = get_stock_grade(symbol, db)
    
    # Get score history
    score_history_result = db.execute(
        select(
            DimDate.full_date,
            DimScoreType.score_type_name,
            FactScoreHistory.score
        )
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .join(DimScoreType, DimScoreType.score_type_key == FactScoreHistory.score_type_key)
        .where(
            and_(
                FactScoreHistory.stock_key == stock.stock_key,
                DimDate.full_date >= datetime.now().date() - timedelta(days=days)
            )
        )
        .order_by(DimDate.full_date.desc())
    ).all()
    
    score_history = [
        {
            "date": str(date),
            "score_type": score_type,
            "score": float(score)
        }
        for date, score_type, score in score_history_result
    ]
    
    # Get AI analysis summary via the consolidated view (latest)
    ai_view = db.execute(
        select(VwAiAnalysisFull)
        .where(VwAiAnalysisFull.symbol == stock.symbol)
        .order_by(VwAiAnalysisFull.as_of_date.desc())
        .limit(1)
    ).scalar_one_or_none()
    
    recent_news = []
    if ai_view and ai_view.headline_risks:
        # Use aggregated headline_risks from the view
        recent_news = [
            {
                "headline": risk,
                "analysis_date": str(ai_view.as_of_date) if ai_view.as_of_date else None,
                "type": "headline_risk",
            }
            for risk in (ai_view.headline_risks or [])
        ]
    
    # Process AI analysis data if available
    ai_analysis_data = None
    
    if ai_view:
        ai_analysis_data = {
            "commentary": ai_view.commentary,
            "market_cap": float(ai_view.market_cap_usd) if ai_view.market_cap_usd is not None else None,
            "beta": float(ai_view.beta_sp500) if ai_view.beta_sp500 is not None else None,
            "news_sentiment_30d": float(ai_view.news_sentiment_30d) if ai_view.news_sentiment_30d is not None else None,
            "social_sentiment_7d": float(ai_view.social_sentiment_7d) if ai_view.social_sentiment_7d is not None else None,
            "revenue_cagr_3y": float(ai_view.revenue_cagr_3y_pct) if ai_view.revenue_cagr_3y_pct is not None else None,
            "rate_sensitivity": float(ai_view.rate_sensitivity_bps) if ai_view.rate_sensitivity_bps is not None else None,
            "fx_sensitivity": ai_view.fx_sensitivity,
            "commodity_exposure": ai_view.commodity_exposure,
            "options_skew_30d": float(ai_view.options_skew_30d) if ai_view.options_skew_30d is not None else None,
            "short_interest_pct": float(ai_view.short_interest_pct_float) if ai_view.short_interest_pct_float is not None else None,
            "employee_score": float(ai_view.employee_glassdoor_score) if ai_view.employee_glassdoor_score is not None else None,
            "headline_buzz": ai_view.headline_buzz_score,
            # Extra fields from the view
            "valuation": {
                "pe_forward": float(ai_view.pe_forward) if ai_view.pe_forward is not None else None,
                "ev_ebitda_forward": float(ai_view.ev_ebitda_forward) if ai_view.ev_ebitda_forward is not None else None,
                "pe_percentile_in_sector": float(ai_view.pe_percentile_in_sector) if ai_view.pe_percentile_in_sector is not None else None,
            },
            "factor_scores": {
                "value": float(ai_view.value_score) if ai_view.value_score is not None else None,
                "quality": float(ai_view.quality_score) if ai_view.quality_score is not None else None,
                "momentum": float(ai_view.momentum_score) if ai_view.momentum_score is not None else None,
                "low_vol": float(ai_view.low_vol_score) if ai_view.low_vol_score is not None else None,
            },
            "scenarios": {
                "bull": {"price": float(ai_view.bull_price_target) if ai_view.bull_price_target is not None else None, "probability_pct": float(ai_view.bull_probability_pct) if ai_view.bull_probability_pct is not None else None},
                "base": {"price": float(ai_view.base_price_target) if ai_view.base_price_target is not None else None, "probability_pct": float(ai_view.base_probability_pct) if ai_view.base_probability_pct is not None else None},
                "bear": {"price": float(ai_view.bear_price_target) if ai_view.bear_price_target is not None else None, "probability_pct": float(ai_view.bear_probability_pct) if ai_view.bear_probability_pct is not None else None},
            },
            "catalysts": {
                "shortTerm": ai_view.short_catalysts if ai_view.short_catalysts is not None else [],
                "longTerm": ai_view.long_catalysts if ai_view.long_catalysts is not None else [],
            },
            "risks": {
                "macro": ai_view.macro_risks if ai_view.macro_risks is not None else [],
                "headline": ai_view.headline_risks if ai_view.headline_risks is not None else [],
                "data_gaps": ai_view.data_gaps if ai_view.data_gaps is not None else [],
            },
            "peers": ai_view.peers if ai_view.peers is not None else [],
        }
    
    asset_detail = AssetDetail(
        symbol=stock.symbol,
        company_name=stock.company_name,
        sector=stock.sector,
        exchange=stock.exchange,
        current_grade=current_grade,
        score_history=score_history,
        recent_news=recent_news,
        ai_analysis=ai_analysis_data
    )
    set_json(cache_key, asset_detail.model_dump(), ttl_secs=asset_ttl)
    return asset_detail


@router.get("/refresh", status_code=status.HTTP_200_OK)
def refresh_grading_cache(db: Session = Depends(get_db)):
    """
    Refresh the grading cache to reflect latest data.
    This endpoint is called by the Airflow DAG after data updates.
    """
    # In a production system, this would clear any caching layer
    # For now, we just verify the data is fresh
    latest_date = db.execute(
        select(func.max(DimDate.full_date))
        .join(FactScoreHistory, FactScoreHistory.date_key == DimDate.date_key)
    ).scalar()
    
    # Invalidate cached pages so the frontend picks up fresh data
    invalidated = {
        "grades": invalidate_prefix("grades:"),
        "grade": invalidate_prefix("grade:"),
        "asset": invalidate_prefix("asset:"),
        "httpcache": invalidate_prefix("httpcache:"),
    }
    # Attempt to refresh materialized view for latest grades (no-op if absent)
    try:
        db.execute(text("REFRESH MATERIALIZED VIEW CONCURRENTLY rankalpha.mv_latest_grades"))
        db.commit()
        mv_refreshed = True
    except Exception:
        try:
            db.execute(text("REFRESH MATERIALIZED VIEW rankalpha.mv_latest_grades"))
            db.commit()
            mv_refreshed = True
        except Exception:
            mv_refreshed = False

    return {
        "status": "success",
        "message": "Grading cache refreshed",
        "latest_data_date": str(latest_date) if latest_date else None,
        "timestamp": datetime.utcnow().isoformat(),
        "invalidated_keys": invalidated,
        "mv_latest_grades_refreshed": mv_refreshed,
    }
