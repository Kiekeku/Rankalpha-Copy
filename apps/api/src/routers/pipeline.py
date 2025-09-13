from __future__ import annotations

from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import select, func, and_, desc
from pydantic import BaseModel, Field

from ..database import get_db
from apps.common.src.models import (
    DimDate,
    FactScoreHistory,
    FactNewsArticles,
    FactNewsSentiment,
    FactFinFundamental,
    DimSource,
    FactScreenerRank,
    FactAiStockAnalysis
)


class PipelineStatus(BaseModel):
    component: str
    status: str  # healthy, warning, error
    last_run: Optional[datetime] = None
    records_processed: Optional[int] = None
    message: str
    data_freshness: Optional[Dict[str, Any]] = None


class DataFreshness(BaseModel):
    table: str
    latest_date: date
    days_behind: int
    status: str  # current, stale, critical


class PipelineHealth(BaseModel):
    overall_status: str
    components: List[PipelineStatus]
    data_freshness: List[DataFreshness]
    last_check: datetime


router = APIRouter(tags=["pipeline"], prefix="/api/v1/pipeline")


def check_data_freshness(db: Session, table_name: str, date_column: str, fact_table: Any) -> DataFreshness:
    """
    Check data freshness for a specific table.
    """
    # Get latest date in table
    latest_date_result = db.execute(
        select(func.max(DimDate.full_date))
        .join(fact_table, getattr(fact_table, date_column) == DimDate.date_key)
    ).scalar()
    
    if not latest_date_result:
        return DataFreshness(
            table=table_name,
            latest_date=date.today(),
            days_behind=999,
            status="critical"
        )
    
    days_behind = (date.today() - latest_date_result).days
    
    if days_behind <= 1:
        status = "current"
    elif days_behind <= 3:
        status = "stale"
    else:
        status = "critical"
    
    return DataFreshness(
        table=table_name,
        latest_date=latest_date_result,
        days_behind=days_behind,
        status=status
    )


@router.get("/health", response_model=PipelineHealth)
def get_pipeline_health(db: Session = Depends(get_db)):
    """
    Get overall pipeline health status and data freshness.
    """
    components = []
    
    # Check Ingestion component
    ingestion_last_run = db.execute(
        select(func.max(FactScoreHistory.load_ts))
    ).scalar()
    
    ingestion_records = db.execute(
        select(func.count(FactScoreHistory.fact_id))
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .where(DimDate.full_date >= date.today() - timedelta(days=1))
    ).scalar()
    
    if ingestion_last_run:
        # Make datetime comparison timezone-aware
        now = datetime.now(timezone.utc) if ingestion_last_run.tzinfo else datetime.now()
        days_since_run = (now - ingestion_last_run).days
        
        if days_since_run <= 1:
            ingestion_status = "healthy"
            ingestion_message = f"Processed {ingestion_records} records in last run"
        elif days_since_run <= 3:
            ingestion_status = "warning"
            ingestion_message = "Ingestion running behind schedule"
        else:
            ingestion_status = "error"
            ingestion_message = "Ingestion has not run recently"
    else:
        ingestion_status = "error"
        ingestion_message = "Ingestion has not run recently"
    
    components.append(PipelineStatus(
        component="ingestion",
        status=ingestion_status,
        last_run=ingestion_last_run,
        records_processed=ingestion_records,
        message=ingestion_message
    ))
    
    # Check Scorer component
    scorer_last_run = db.execute(
        select(func.max(FactScoreHistory.load_ts))
    ).scalar()
    
    scorer_records = db.execute(
        select(func.count(func.distinct(FactScoreHistory.stock_key)))
        .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
        .where(DimDate.full_date >= date.today() - timedelta(days=1))
    ).scalar()
    
    if scorer_last_run:
        # Make datetime comparison timezone-aware
        now = datetime.now(timezone.utc) if scorer_last_run.tzinfo else datetime.now()
        days_since_run = (now - scorer_last_run).days
        
        if days_since_run <= 1:
            scorer_status = "healthy"
            scorer_message = f"Scored {scorer_records} stocks in last run"
        else:
            scorer_status = "warning"
            scorer_message = "Scorer may be behind schedule"
    else:
        scorer_status = "warning"
        scorer_message = "Scorer may be behind schedule"
    
    components.append(PipelineStatus(
        component="scorer",
        status=scorer_status,
        last_run=scorer_last_run,
        records_processed=scorer_records,
        message=scorer_message
    ))
    
    # Check Sentiment component (AI Analysis)
    sentiment_last_run = db.execute(
        select(func.max(FactAiStockAnalysis.load_ts))
    ).scalar()
    
    sentiment_records = db.execute(
        select(func.count(FactAiStockAnalysis.analysis_id))
        .where(FactAiStockAnalysis.news_sentiment_30d.is_not(None))
    ).scalar()
    
    if sentiment_last_run:
        # Make datetime comparison timezone-aware
        now = datetime.now(timezone.utc) if sentiment_last_run.tzinfo else datetime.now()
        days_since_run = (now - sentiment_last_run).days
        
        if days_since_run <= 7:
            sentiment_status = "healthy"
            sentiment_message = f"AI analyzed {sentiment_records} stocks with sentiment data"
        else:
            sentiment_status = "warning"
            sentiment_message = "Sentiment analysis may need attention"
    else:
        sentiment_status = "warning"
        sentiment_message = "Sentiment analysis may need attention"
    
    components.append(PipelineStatus(
        component="sentiment",
        status=sentiment_status,
        last_run=sentiment_last_run,
        records_processed=sentiment_records,
        message=sentiment_message
    ))
    
    # Check data freshness for key tables
    freshness_checks = [
        check_data_freshness(db, "fact_score_history", "date_key", FactScoreHistory),
        check_data_freshness(db, "fact_news_articles", "article_date", FactNewsArticles),
        check_data_freshness(db, "fact_screener_rank", "date_key", FactScreenerRank),
    ]
    
    # Determine overall status
    all_statuses = [c.status for c in components]
    if any(s == "error" for s in all_statuses):
        overall_status = "error"
    elif any(s == "warning" for s in all_statuses):
        overall_status = "warning"
    else:
        overall_status = "healthy"
    
    return PipelineHealth(
        overall_status=overall_status,
        components=components,
        data_freshness=freshness_checks,
        last_check=datetime.now()
    )


@router.get("/status/{component}")
def get_component_status(
    component: str,
    db: Session = Depends(get_db)
):
    """
    Get detailed status for a specific pipeline component.
    """
    valid_components = ["ingestion", "scorer", "sentiment", "fundamental"]
    
    if component not in valid_components:
        raise HTTPException(
            status_code=404,
            detail=f"Component '{component}' not found. Valid components: {', '.join(valid_components)}"
        )
    
    if component == "ingestion":
        # Get recent ingestion runs
        recent_runs = db.execute(
            select(
                DimDate.full_date,
                func.count(FactScoreHistory.fact_id).label('records'),
                func.min(FactScoreHistory.load_ts).label('start_time'),
                func.max(FactScoreHistory.load_ts).label('end_time')
            )
            .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
            .where(DimDate.full_date >= date.today() - timedelta(days=7))
            .group_by(DimDate.full_date)
            .order_by(desc(DimDate.full_date))
        ).all()
        
        return {
            "component": component,
            "recent_runs": [
                {
                    "date": str(run_date),
                    "records_processed": records,
                    "start_time": start_time.isoformat() if start_time else None,
                    "end_time": end_time.isoformat() if end_time else None,
                    "duration_seconds": (end_time - start_time).total_seconds() if start_time and end_time else None
                }
                for run_date, records, start_time, end_time in recent_runs
            ]
        }
    
    elif component == "scorer":
        # Get scoring statistics
        score_stats = db.execute(
            select(
                func.count(func.distinct(FactScoreHistory.stock_key)).label('unique_stocks'),
                func.count(func.distinct(FactScoreHistory.score_type_key)).label('score_types'),
                func.count(FactScoreHistory.fact_id).label('total_scores')
            )
            .join(DimDate, DimDate.date_key == FactScoreHistory.date_key)
            .where(DimDate.full_date >= date.today() - timedelta(days=1))
        ).first()
        
        return {
            "component": component,
            "statistics": {
                "unique_stocks": score_stats.unique_stocks if score_stats else 0,
                "score_types": score_stats.score_types if score_stats else 0,
                "total_scores": score_stats.total_scores if score_stats else 0
            }
        }
    
    elif component == "sentiment":
        # Get sentiment analysis statistics
        sentiment_stats = db.execute(
            select(
                func.count(FactNewsSentiment.article_id).label('analyzed_articles'),
                func.avg(FactNewsSentiment.sentiment_score).label('avg_sentiment')
            )
            .join(FactNewsArticles, FactNewsArticles.article_id == FactNewsSentiment.article_id)
            .join(DimDate, DimDate.date_key == FactNewsArticles.article_date)
            .where(DimDate.full_date >= date.today() - timedelta(days=7))
        ).first()
        
        return {
            "component": component,
            "statistics": {
                "analyzed_articles_7d": sentiment_stats.analyzed_articles if sentiment_stats else 0,
                "average_sentiment": float(sentiment_stats.avg_sentiment) if sentiment_stats and sentiment_stats.avg_sentiment else 0
            }
        }
    
    else:  # fundamental
        # Get fundamental data statistics
        fundamental_stats = db.execute(
            select(
                func.count(func.distinct(FactFinFundamental.stock_key)).label('stocks_with_data'),
                func.count(func.distinct(FactFinFundamental.metric_key)).label('unique_metrics'),
                func.max(FactFinFundamental.load_ts).label('last_update')
            )
        ).first()
        
        return {
            "component": component,
            "statistics": {
                "stocks_with_fundamentals": fundamental_stats.stocks_with_data if fundamental_stats else 0,
                "unique_metrics": fundamental_stats.unique_metrics if fundamental_stats else 0,
                "last_update": fundamental_stats.last_update.isoformat() if fundamental_stats and fundamental_stats.last_update else None
            }
        }


@router.get("/airflow-status")
def get_airflow_status():
    """
    Get Airflow status and provide link to UI.
    Note: In production, this would integrate with Airflow API.
    """
    return {
        "airflow_ui_url": "http://localhost:8080",
        "credentials": {
            "username": "rankalpha",
            "password": "rankalpha"
        },
        "message": "Access Airflow UI for detailed DAG status and logs",
        "dags": [
            {
                "dag_id": "data_pipeline",
                "description": "Main data ingestion and scoring pipeline",
                "schedule": "0 2 * * *",  # Daily at 2 AM
                "status": "running"
            },
            {
                "dag_id": "sentiment_analysis",
                "description": "News sentiment analysis pipeline",
                "schedule": "0 */6 * * *",  # Every 6 hours
                "status": "paused"
            }
        ]
    }


@router.get("/data-quality")
def check_data_quality(db: Session = Depends(get_db)):
    """
    Check for data quality issues.
    """
    issues = []
    
    # Check for missing dates in score history
    missing_dates = db.execute(
        select(DimDate.full_date)
        .outerjoin(FactScoreHistory, FactScoreHistory.date_key == DimDate.date_key)
        .where(
            and_(
                DimDate.is_trading_day == True,
                DimDate.full_date >= date.today() - timedelta(days=30),
                DimDate.full_date < date.today(),
                FactScoreHistory.fact_id.is_(None)
            )
        )
    ).scalars().all()
    
    if missing_dates:
        issues.append({
            "type": "missing_data",
            "severity": "warning",
            "description": f"Missing score data for {len(missing_dates)} trading days",
            "dates": [str(d) for d in missing_dates[:5]]  # Show first 5
        })
    
    # Check for duplicate entries
    duplicates = db.execute(
        select(
            FactScoreHistory.stock_key,
            FactScoreHistory.date_key,
            FactScoreHistory.score_type_key,
            func.count(FactScoreHistory.fact_id).label('count')
        )
        .group_by(
            FactScoreHistory.stock_key,
            FactScoreHistory.date_key,
            FactScoreHistory.score_type_key
        )
        .having(func.count(FactScoreHistory.fact_id) > 1)
    ).all()
    
    if duplicates:
        issues.append({
            "type": "duplicate_data",
            "severity": "error",
            "description": f"Found {len(duplicates)} duplicate score entries",
            "count": len(duplicates)
        })
    
    # Check for anomalous scores
    anomalous_scores = db.execute(
        select(func.count(FactScoreHistory.fact_id))
        .where(
            or_(
                FactScoreHistory.score < 0,
                FactScoreHistory.score > 100
            )
        )
    ).scalar()
    
    if anomalous_scores:
        issues.append({
            "type": "anomalous_values",
            "severity": "warning",
            "description": f"Found {anomalous_scores} scores outside valid range (0-100)",
            "count": anomalous_scores
        })
    
    return {
        "status": "error" if any(i["severity"] == "error" for i in issues) else "warning" if issues else "healthy",
        "issues": issues,
        "checked_at": datetime.now().isoformat()
    }
