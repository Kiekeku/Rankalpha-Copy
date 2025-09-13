from __future__ import annotations

from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import select, func, and_, or_, desc, asc
from pydantic import BaseModel, Field

from ..database import get_db
from apps.common.src.models import (
    DimStock, 
    FactScoreHistory,
    DimScoreType,
    DimDate,
    VwScoreHistory,
    VLatestScreenerValues,
    FactScreenerRank,
    DimStyle
)


class SignalScore(BaseModel):
    symbol: str
    company_name: Optional[str] = None
    sector: Optional[str] = None
    score_type: str
    score: float
    rank: Optional[int] = None
    date: date
    percentile: Optional[float] = None


class SignalsLeaderboard(BaseModel):
    signals: List[SignalScore]
    total_count: int
    page: int
    page_size: int
    as_of_date: date


class SignalComparison(BaseModel):
    symbol: str
    signals: Dict[str, float]
    average_score: float
    recommendation: str


router = APIRouter(tags=["signals"], prefix="/api/v1/signals")


@router.get("/leaderboard", response_model=SignalsLeaderboard)
def get_signals_leaderboard(
    db: Session = Depends(get_db),
    signal_type: str = Query("LINREG_200", description="Type of signal/score"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=500),
    sector: Optional[str] = None,
    min_score: Optional[float] = None,
    max_score: Optional[float] = None,
    date_str: Optional[str] = None
):
    """
    Get signals leaderboard with pagination and filtering.
    """
    # Parse date or use latest
    if date_str:
        try:
            target_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
    else:
        # Get latest date
        latest_date_result = db.execute(
            select(func.max(DimDate.full_date))
            .join(FactScoreHistory, FactScoreHistory.date_key == DimDate.date_key)
        ).scalar()
        
        if not latest_date_result:
            raise HTTPException(status_code=404, detail="No data available")
        
        target_date = latest_date_result
    
    # Get score type
    score_type = db.execute(
        select(DimScoreType).where(DimScoreType.score_type_name == signal_type)
    ).scalar_one_or_none()
    
    if not score_type:
        # Get available score types
        available_types = db.execute(
            select(DimScoreType.score_type_name).distinct()
        ).scalars().all()
        
        raise HTTPException(
            status_code=404, 
            detail=f"Signal type '{signal_type}' not found. Available types: {', '.join(available_types)}"
        )
    
    # Build query
    query = (
        select(
            DimStock.symbol,
            DimStock.company_name,
            DimStock.sector,
            FactScoreHistory.score,
            DimDate.full_date
        )
        .join(DimStock, DimStock.stock_key == FactScoreHistory.stock_key)
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .where(
            and_(
                FactScoreHistory.score_type_key == score_type.score_type_key,
                DimDate.full_date == target_date,
                DimStock.is_active.is_(True)
            )
        )
    )
    
    # Apply filters
    if sector:
        query = query.where(DimStock.sector == sector)
    
    if min_score is not None:
        query = query.where(FactScoreHistory.score >= min_score)
    
    if max_score is not None:
        query = query.where(FactScoreHistory.score <= max_score)
    
    # Get total count before pagination
    count_query = select(func.count()).select_from(query.subquery())
    total_count = db.execute(count_query).scalar()
    
    # Apply sorting and pagination
    query = query.order_by(desc(FactScoreHistory.score))
    query = query.offset(skip).limit(limit)
    
    results = db.execute(query).all()
    
    # Calculate ranks and percentiles
    all_scores = db.execute(
        select(FactScoreHistory.score)
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .where(
            and_(
                FactScoreHistory.score_type_key == score_type.score_type_key,
                DimDate.full_date == target_date
            )
        )
        .order_by(desc(FactScoreHistory.score))
    ).scalars().all()
    
    signals = []
    for i, (symbol, company_name, sector_name, score, date_val) in enumerate(results):
        # Calculate percentile
        percentile = None
        if all_scores:
            rank_position = next((idx for idx, s in enumerate(all_scores) if float(s) == float(score)), None)
            if rank_position is not None:
                percentile = 100.0 * (1 - rank_position / len(all_scores))
        
        signals.append(SignalScore(
            symbol=symbol,
            company_name=company_name,
            sector=sector_name,
            score_type=signal_type,
            score=float(score),
            rank=skip + i + 1,
            date=date_val,
            percentile=percentile
        ))
    
    return SignalsLeaderboard(
        signals=signals,
        total_count=total_count,
        page=skip // limit + 1,
        page_size=limit,
        as_of_date=target_date
    )


@router.get("/compare", response_model=List[SignalComparison])
def compare_signals(
    db: Session = Depends(get_db),
    symbols: str = Query(..., description="Comma-separated list of symbols"),
    signal_types: Optional[str] = Query(None, description="Comma-separated signal types")
):
    """
    Compare multiple signals across stocks.
    """
    symbol_list = [s.strip().upper() for s in symbols.split(",")]
    
    if signal_types:
        signal_type_list = [s.strip() for s in signal_types.split(",")]
    else:
        # Default signal types
        signal_type_list = ["LINREG_200", "LINREG_90", "LINREG_50", "LINREG_30", "SMA_200"]
    
    # Get latest date
    latest_date_result = db.execute(
        select(func.max(DimDate.full_date))
        .join(FactScoreHistory, FactScoreHistory.date_key == DimDate.date_key)
    ).scalar()
    
    if not latest_date_result:
        raise HTTPException(status_code=404, detail="No data available")
    
    comparisons = []
    
    for symbol in symbol_list:
        stock = db.execute(
            select(DimStock).where(func.upper(DimStock.symbol) == symbol)
        ).scalar_one_or_none()
        
        if not stock:
            continue
        
        signals_dict = {}
        
        for signal_type in signal_type_list:
            score_type = db.execute(
                select(DimScoreType).where(DimScoreType.score_type_name == signal_type)
            ).scalar_one_or_none()
            
            if not score_type:
                continue
            
            score_result = db.execute(
                select(FactScoreHistory.score)
                .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
                .where(
                    and_(
                        FactScoreHistory.stock_key == stock.stock_key,
                        FactScoreHistory.score_type_key == score_type.score_type_key,
                        DimDate.full_date == latest_date_result
                    )
                )
            ).scalar()
            
            if score_result:
                signals_dict[signal_type] = float(score_result)
        
        if signals_dict:
            avg_score = sum(signals_dict.values()) / len(signals_dict)
            
            # Simple recommendation logic
            if avg_score >= 70:
                recommendation = "Strong Buy"
            elif avg_score >= 55:
                recommendation = "Buy"
            elif avg_score >= 45:
                recommendation = "Hold"
            elif avg_score >= 30:
                recommendation = "Sell"
            else:
                recommendation = "Strong Sell"
            
            comparisons.append(SignalComparison(
                symbol=symbol,
                signals=signals_dict,
                average_score=avg_score,
                recommendation=recommendation
            ))
    
    return comparisons


@router.get("/historical/{symbol}")
def get_signal_history(
    symbol: str,
    db: Session = Depends(get_db),
    signal_type: str = Query("LINREG_200"),
    days: int = Query(90, ge=1, le=365)
):
    """
    Get historical signal data for a specific stock.
    """
    stock = db.execute(
        select(DimStock).where(func.upper(DimStock.symbol) == symbol.upper(), DimStock.is_active.is_(True))
    ).scalar_one_or_none()
    
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found")
    
    score_type = db.execute(
        select(DimScoreType).where(DimScoreType.score_type_name == signal_type)
    ).scalar_one_or_none()
    
    if not score_type:
        raise HTTPException(status_code=404, detail=f"Signal type {signal_type} not found")
    
    # Get historical data
    history = db.execute(
        select(
            DimDate.full_date,
            FactScoreHistory.score
        )
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .where(
            and_(
                FactScoreHistory.stock_key == stock.stock_key,
                FactScoreHistory.score_type_key == score_type.score_type_key,
                DimDate.full_date >= datetime.now().date() - timedelta(days=days)
            )
        )
        .order_by(DimDate.full_date)
    ).all()
    
    return {
        "symbol": symbol,
        "signal_type": signal_type,
        "history": [
            {"date": str(date), "score": float(score)}
            for date, score in history
        ]
    }


@router.get("/universe")
def get_signal_universe(
    db: Session = Depends(get_db),
    date_str: Optional[str] = None
):
    """
    Get the current universe of stocks with signals.
    """
    if date_str:
        try:
            target_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
    else:
        # Get latest date
        latest_date_result = db.execute(
            select(func.max(DimDate.full_date))
            .join(FactScoreHistory, FactScoreHistory.date_key == DimDate.date_key)
        ).scalar()
        
        if not latest_date_result:
            raise HTTPException(status_code=404, detail="No data available")
        
        target_date = latest_date_result
    
    # Get unique stocks with scores on target date
    stocks_with_scores = db.execute(
        select(
            DimStock.symbol,
            DimStock.company_name,
            DimStock.sector,
            func.count(FactScoreHistory.score_type_key).label('signal_count')
        )
        .join(DimStock, DimStock.stock_key == FactScoreHistory.stock_key)
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .where(and_(DimDate.full_date == target_date, DimStock.is_active.is_(True)))
        .group_by(DimStock.symbol, DimStock.company_name, DimStock.sector)
        .order_by(DimStock.symbol)
    ).all()
    
    # Get sector breakdown
    sector_breakdown = db.execute(
        select(
            DimStock.sector,
            func.count(func.distinct(DimStock.stock_key)).label('count')
        )
        .join(FactScoreHistory, FactScoreHistory.stock_key == DimStock.stock_key)
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .where(and_(DimDate.full_date == target_date, DimStock.is_active.is_(True)))
        .group_by(DimStock.sector)
    ).all()
    
    return {
        "as_of_date": str(target_date),
        "total_stocks": len(stocks_with_scores),
        "stocks": [
            {
                "symbol": symbol,
                "company_name": company_name,
                "sector": sector,
                "signal_count": signal_count
            }
            for symbol, company_name, sector, signal_count in stocks_with_scores
        ],
        "sector_breakdown": {
            sector: count for sector, count in sector_breakdown
        }
    }
