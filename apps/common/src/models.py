from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    CHAR,
    CheckConstraint,
    Column,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
    ARRAY, 
    Enum,
    func,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship


trade_action_enum = Enum(
    'BUY', 'SELL',
    name='trade_action',
    create_type=False,        # the type already exists in Postgres
    native_enum=False         # map to the existing domain
)


Base = declarative_base()

class DimFinMetric(Base):
    __tablename__ = "dim_fin_metric"
    __table_args__ = (
        UniqueConstraint("metric_code", name="dim_fin_metric_metric_code_key"),
        {"schema": "rankalpha"},
    )

    metric_key = Column(Integer, primary_key=True)
    metric_code = Column(String(60), nullable=False)
    metric_name = Column(Text, nullable=False)
    stmt_code = Column(String(64), nullable=False)
    default_unit = Column(String(64), server_default="USD")

    fundamentals = relationship("FactFinFundamental", back_populates="metric")


class DimSource(Base):
    __tablename__ = "dim_source"
    __table_args__ = (
        UniqueConstraint("source_name", name="dim_source_source_name_key"),
        {"schema": "rankalpha"},
    )

    source_key = Column(Integer, primary_key=True)
    source_name = Column(String(50), nullable=False)
    version = Column(String(20), nullable=False, default="1")

    fundamentals = relationship("FactFinFundamental", back_populates="source")
    news_articles = relationship("FactNewsArticles", back_populates="source")


class DimStyle(Base):
    __tablename__ = "dim_style"
    __table_args__ = {"schema": "rankalpha"}

    style_key = Column(Integer, primary_key=True)
    style_name = Column(String(50), unique=True, nullable=False)


class DimDate(Base):
    __tablename__ = "dim_date"
    __table_args__ = {"schema": "rankalpha"}

    date_key = Column(Integer, primary_key=True)
    full_date = Column(Date, unique=True, nullable=False)
    day_of_week = Column(SmallInteger, nullable=False)
    month_num = Column(SmallInteger, nullable=False)
    month_name = Column(String(10), nullable=False)
    quarter = Column(SmallInteger, nullable=False)
    calendar_year = Column(SmallInteger, nullable=False)
    is_trading_day = Column(Boolean, default=True, nullable=False)


class DimScoreType(Base):
    __tablename__ = "dim_score_type"
    __table_args__ = {"schema": "rankalpha"}

    score_type_key = Column(Integer, primary_key=True)
    score_type_name = Column(String(50), unique=True, nullable=False)


class DimCorrMethod(Base):
    __tablename__ = "dim_corr_method"
    __table_args__ = {"schema": "rankalpha"}

    corr_method_key = Column(Integer, primary_key=True)
    corr_method_name = Column(String(40), unique=True, nullable=False)


class DimCorrWindow(Base):
    __tablename__ = "dim_corr_window"
    __table_args__ = {"schema": "rankalpha"}

    corr_window_key = Column(Integer, primary_key=True)
    window_label = Column(String(30), unique=True, nullable=False)
    window_days = Column(Integer, nullable=False)


class FactFinFundamental(Base):
    __tablename__ = "fact_fin_fundamentals"
    __table_args__ = (
        {"schema": "rankalpha"},
    )

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), primary_key=True)
  
    metric_key = Column(Integer, ForeignKey("rankalpha.dim_fin_metric.metric_key"), primary_key=True)

    fact_id = Column(UUID(as_uuid=True), default=uuid.uuid4)
    source_key = Column(Integer, ForeignKey("rankalpha.dim_source.source_key"), nullable=False)
    fiscal_year = Column(SmallInteger, nullable=False)
    fiscal_period = Column(String(3), nullable=False)
    metric_value = Column(Numeric(20, 4), nullable=False)
    restated = Column(Boolean, default=False)
    ttm_flag = Column(Boolean, default=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)

    stock = relationship("DimStock", back_populates="fundamentals")
    metric = relationship("DimFinMetric", back_populates="fundamentals")
    source = relationship("DimSource", back_populates="fundamentals")
    date = relationship("DimDate")


class FactScreenerRank(Base):
    __tablename__ = "fact_screener_rank"
    __table_args__ = {"schema": "rankalpha"}

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    fact_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    source_key = Column(Integer, ForeignKey("rankalpha.dim_source.source_key"), nullable=False)
    style_key = Column(Integer, ForeignKey("rankalpha.dim_style.style_key"), nullable=True)
    rank_value = Column(Integer, nullable=False)
    screening_runid = Column(UUID(as_uuid=True), nullable=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)


class FactStockScores(Base):
    __tablename__ = "fact_stock_scores"
    __table_args__ = {"schema": "rankalpha"}

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    fact_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    style_key = Column(Integer, ForeignKey("rankalpha.dim_style.style_key"), nullable=False)
    score_value = Column(Numeric(5, 2), nullable=False)
    rank_value = Column(Integer, nullable=False)
    score_runid = Column(UUID(as_uuid=True), nullable=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)


class FactStockScoreType(Base):
    __tablename__ = "fact_stock_score_types"
    __table_args__ = {"schema": "rankalpha"}

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    fact_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    score_type_key = Column(Integer, ForeignKey("rankalpha.dim_score_type.score_type_key"), nullable=False)
    score_value = Column(Numeric(5, 2), nullable=False)
    rank_value = Column(Integer, nullable=False)
    score_runid = Column(UUID(as_uuid=True), nullable=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)


class FactScoreHistory(Base):
    __tablename__ = "fact_score_history"
    __table_args__ = {"schema": "rankalpha"}

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    fact_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    source_key = Column(Integer, ForeignKey("rankalpha.dim_source.source_key"), nullable=False)
    score_type_key = Column(Integer, ForeignKey("rankalpha.dim_score_type.score_type_key"), nullable=False)
    score = Column(Numeric(10, 2), nullable=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)


class FactNewsArticles(Base):
    __tablename__ = "fact_news_articles"
    __table_args__ = {"schema": "rankalpha"}

    article_date = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    article_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    source_key = Column(Integer, ForeignKey("rankalpha.dim_source.source_key"), nullable=False)
    headline = Column(Text, nullable=False)
    content = Column(Text, nullable=False)
    url = Column(Text, nullable=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)

    sentiment = relationship(
        "FactNewsSentiment", back_populates="article", uselist=False
    )
    stock = relationship("DimStock", back_populates="news_articles")
    source = relationship("DimSource", back_populates="news_articles")
    date = relationship("DimDate")


class FactNewsSentiment(Base):
    __tablename__ = "fact_news_sentiment"
    __table_args__ = {"schema": "rankalpha"}

    article_id = Column(
        UUID(as_uuid=True),
        ForeignKey("rankalpha.fact_news_articles.article_id"),
        primary_key=True,
    )
    sentiment_score = Column(Numeric(5, 3), nullable=False)
    sentiment_label = Column(String(20), nullable=False)
    analysis_runid = Column(UUID(as_uuid=True), nullable=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)

    article = relationship("FactNewsArticles", back_populates="sentiment")


class FactStockCorrelation(Base):
    __tablename__ = "fact_stock_correlation"
    __table_args__ = (
        CheckConstraint("stock1_key < stock2_key", name="chk_stock_order"),
        CheckConstraint(
            "correlation_value >= -1 AND correlation_value <= 1", name="fact_stock_correlation_correlation_value_check"
        ),
        {"schema": "rankalpha"},
    )

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    fact_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stock1_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    stock2_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    corr_method_key = Column(Integer, ForeignKey("rankalpha.dim_corr_method.corr_method_key"), nullable=False)
    corr_window_key = Column(Integer, ForeignKey("rankalpha.dim_corr_window.corr_window_key"), nullable=False)
    correlation_value = Column(Numeric(6, 4), nullable=False)
    corr_runid = Column(UUID(as_uuid=True), nullable=False)
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)


class DimAssetType(Base):
    __tablename__ = "dim_asset_type"
    __table_args__ = {"schema": "rankalpha"}

    asset_type_key = Column(Integer, primary_key=True)
    asset_type_name = Column(String(20), unique=True, nullable=False)

    stocks = relationship("DimStock", back_populates="asset_type")

class DimRating(Base):
    __tablename__ = "dim_rating"
    __table_args__ = {"schema": "rankalpha"}

    rating_key = Column(Integer, primary_key=True)
    rating_label = Column(String(20), unique=True, nullable=False)


class DimConfidence(Base):
    __tablename__ = "dim_confidence"
    __table_args__ = {"schema": "rankalpha"}

    confidence_key = Column(Integer, primary_key=True)
    confidence_label = Column(String(10), unique=True, nullable=False)


class DimTimeframe(Base):
    __tablename__ = "dim_timeframe"
    __table_args__ = {"schema": "rankalpha"}

    timeframe_key = Column(Integer, primary_key=True)
    timeframe_label = Column(String(12), unique=True, nullable=False)


class DimTrendCategory(Base):
    __tablename__ = "dim_trend_category"
    __table_args__ = {"schema": "rankalpha"}

    trend_key = Column(Integer, primary_key=True)
    trend_label = Column(String(20), unique=True, nullable=False)

# ── 1.2 PATCH DimStock TO REFERENCE ASSET‑TYPE ────────────
class DimStock(Base):
    __tablename__ = "dim_stock"
    __table_args__ = {"schema": "rankalpha"}

    stock_key = Column(Integer, primary_key=True)
    symbol = Column(String(20), unique=True, nullable=False)
    company_name = Column(Text)
    sector = Column(Text)
    exchange = Column(Text)
    is_active = Column(Boolean, nullable=False, server_default="true")

    asset_type_key = Column(Integer, ForeignKey("rankalpha.dim_asset_type.asset_type_key"))
    asset_type = relationship("DimAssetType", back_populates="stocks")

    # existing relationships …
    fundamentals = relationship("FactFinFundamental", back_populates="stock")
    news_articles = relationship("FactNewsArticles", back_populates="stock")

# ── 1.3 CENTRAL FACT TABLE ────────────────────────────────
class FactAiStockAnalysis(Base):
    __tablename__ = "fact_ai_stock_analysis"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), nullable=False)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), nullable=False)
    source_key = Column(Integer, ForeignKey("rankalpha.dim_source.source_key"), nullable=False)

    # Scalars (sample – add any others you put in Flyway)
    market_cap_usd = Column(Numeric(20, 2))
    revenue_cagr_3y_pct = Column(Numeric(6, 2))

    gross_margin_trend_key = Column(Integer, ForeignKey("rankalpha.dim_trend_category.trend_key"))
    net_margin_trend_key = Column(Integer, ForeignKey("rankalpha.dim_trend_category.trend_key"))
    free_cash_flow_trend_key = Column(Integer, ForeignKey("rankalpha.dim_trend_category.trend_key"))
    insider_activity_key = Column(Integer, ForeignKey("rankalpha.dim_trend_category.trend_key"))

    beta_sp500 = Column(Numeric(6, 4))
    rate_sensitivity_bps = Column(Numeric(10, 2))
    fx_sensitivity = Column(String(8))
    commodity_exposure = Column(String(8))

    news_sentiment_30d = Column(Numeric(5, 2))
    social_sentiment_7d = Column(Numeric(5, 2))
    options_skew_30d = Column(Numeric(7, 3))
    short_interest_pct_float = Column(Numeric(6, 2))
    employee_glassdoor_score = Column(Numeric(4, 2))
    headline_buzz_score = Column(String(6))
    commentary = Column(Text)

    overall_rating_key = Column(Integer, ForeignKey("rankalpha.dim_rating.rating_key"))
    confidence_key = Column(Integer, ForeignKey("rankalpha.dim_confidence.confidence_key"))
    timeframe_key = Column(Integer, ForeignKey("rankalpha.dim_timeframe.timeframe_key"))

    load_ts = Column(DateTime, server_default=func.now(), nullable=False)

    # helpful back‑refs
    stock = relationship("DimStock")
    date = relationship("DimDate")
    source = relationship("DimSource")

    # children: define only if you need ORM navigation
    valuation = relationship("FactAiValuationMetrics", back_populates="analysis", uselist=False)
    peers = relationship("FactAiPeerComparison", back_populates="analysis")
    factor_scores = relationship("FactAiFactorScore", back_populates="analysis")
    catalysts = relationship("FactAiCatalyst", back_populates="analysis")
    scenarios = relationship("FactAiPriceScenario", back_populates="analysis")

# ── 1.4 CHILD FACTS (condensed – keep fields you need) ────
class FactAiValuationMetrics(Base):
    __tablename__ = "fact_ai_valuation_metrics"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), primary_key=True)
    pe_forward = Column(Numeric(10, 2))
    ev_ebitda_forward = Column(Numeric(10, 2))
    pe_percentile_in_sector = Column(Numeric(6, 2))

    analysis = relationship("FactAiStockAnalysis", back_populates="valuation")


class FactAiPeerComparison(Base):
    __tablename__ = "fact_ai_peer_comparison"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), primary_key=True)
    peer_stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), primary_key=True)
    pe_forward = Column(Numeric(10, 2))
    ev_ebitda_forward = Column(Numeric(10, 2))
    return_1y_pct = Column(Numeric(7, 2))
    summary = Column(Text)

    analysis = relationship("FactAiStockAnalysis", back_populates="peers")
    peer_stock = relationship("DimStock")


class FactAiFactorScore(Base):
    __tablename__ = "fact_ai_factor_score"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), primary_key=True)
    style_key = Column(Integer, ForeignKey("rankalpha.dim_style.style_key"), primary_key=True)
    score = Column(Numeric(5, 2), nullable=False)

    analysis = relationship("FactAiStockAnalysis", back_populates="factor_scores")
    style = relationship("DimStyle")


class FactAiCatalyst(Base):
    __tablename__ = "fact_ai_catalyst"
    __table_args__ = {"schema": "rankalpha"}

    catalyst_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), nullable=False)
    catalyst_type = Column(String(10), nullable=False)  # 'short' / 'long'
    title = Column(Text, nullable=False)
    description = Column(Text)
    probability_pct = Column(Numeric(6, 2))
    expected_price_move_pct = Column(Numeric(7, 2))
    expected_date = Column(Date)
    priced_in_pct = Column(Numeric(6, 2))
    price_drop_risk_pct = Column(Numeric(7, 2))

    analysis = relationship("FactAiStockAnalysis", back_populates="catalysts")


class FactAiPriceScenario(Base):
    __tablename__ = "fact_ai_price_scenario"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), primary_key=True)
    scenario_type = Column(String(6), primary_key=True)  # bull / base / bear
    price_target = Column(Numeric(20, 2))
    probability_pct = Column(Numeric(6, 2))

    analysis = relationship("FactAiStockAnalysis", back_populates="scenarios")


class FactAiMacroRisk(Base):
    __tablename__ = "fact_ai_macro_risk"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), primary_key=True)
    risk_text = Column(Text, primary_key=True)


class FactAiHeadlineRisk(Base):
    __tablename__ = "fact_ai_headline_risk"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), primary_key=True)
    risk_text = Column(Text, primary_key=True)


class FactAiDataGap(Base):
    __tablename__ = "fact_ai_data_gap"
    __table_args__ = {"schema": "rankalpha"}

    analysis_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.fact_ai_stock_analysis.analysis_id"), primary_key=True)
    gap_text = Column(Text, primary_key=True)
    
    
# ── FACT: TRADE RECOMMENDATION ────────────────────────────────────────────
class FactTradeRecommendation(Base):
    __tablename__ = "fact_trade_recommendation"
    __table_args__ = {"schema": "rankalpha"}

    recommendation_id = Column(UUID(as_uuid=True),
                               primary_key=True,
                               default=uuid.uuid4)

    date_key      = Column(Integer,
                           ForeignKey("rankalpha.dim_date.date_key"),
                           nullable=False)
    stock_key     = Column(Integer,
                           ForeignKey("rankalpha.dim_stock.stock_key"),
                           nullable=False)
    source_key    = Column(Integer,
                           ForeignKey("rankalpha.dim_source.source_key"),
                           nullable=False)

    action = Column(trade_action_enum, nullable=False)
    recommended_price = Column(Numeric(20, 4))
    stop_loss_price   = Column(Numeric(20, 4))
    take_profit_price = Column(Numeric(20, 4))

    size_shares   = Column(Integer)
    size_percent  = Column(Numeric(6, 2))

    confidence_key = Column(Integer,
                            ForeignKey("rankalpha.dim_confidence.confidence_key"))
    timeframe_key  = Column(Integer,
                            ForeignKey("rankalpha.dim_timeframe.timeframe_key"))

    strategy_name = Column(String(50))
    description   = Column(Text)

    is_live       = Column(Boolean, default=False)
    filled_price  = Column(Numeric(20, 4))
    filled_date   = Column(Date)

    create_ts     = Column(DateTime, server_default=func.now(), nullable=False)
    update_ts     = Column(DateTime, server_default=func.now(), nullable=False)

    # Relationships (handy shortcuts)
    stock  = relationship("DimStock", back_populates="trade_recommendations")
    source = relationship("DimSource")
    date   = relationship("DimDate")

# Add to DimStock for reverse lookup (optional)
DimStock.trade_recommendations = relationship(
    "FactTradeRecommendation",
    back_populates="stock",
    cascade="all, delete-orphan",
)


# ── VIEW: TRADE RECOMMENDATION (READ‑ONLY) ───────────────────────────────
class VwTradeRecommendation(Base):
    __tablename__   = "vw_trade_recommendation"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    # The view re‑exposes recommendation_id, so we can use it as PK
    recommendation_id   = Column(UUID(as_uuid=True), primary_key=True)

    recommendation_date = Column(Date)
    symbol              = Column(String(20))
    exchange            = Column(String)
    asset_type          = Column(String(20))

    source_name         = Column(String(50))
    source_version      = Column(String(20))

    action              = Column(String(5))
    recommended_price   = Column(Numeric(20, 4))
    stop_loss_price     = Column(Numeric(20, 4))
    take_profit_price   = Column(Numeric(20, 4))
    size_shares         = Column(Integer)
    size_percent        = Column(Numeric(6, 2))

    confidence_label    = Column(String(10))
    timeframe_label     = Column(String(12))

    strategy_name       = Column(String(50))
    description         = Column(Text)

    is_live             = Column(Boolean)
    filled_price        = Column(Numeric(20, 4))
    filled_date         = Column(Date)

    create_ts           = Column(DateTime)
    update_ts           = Column(DateTime)
    
class VwNewsSentiment(Base):
    __tablename__   = "vw_news_sentiment"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}  # read‑only

    article_id       = Column(UUID(as_uuid=True), primary_key=True)
    date_key         = Column(Integer)          # 20250629 etc.
    article_date     = Column(Date)             # calendar date
    stock_key        = Column(Integer)
    symbol           = Column(String(20))
    source_key       = Column(Integer)
    source_name      = Column(String(50))
    source_version   = Column(String(20))

    sentiment_score  = Column(Numeric(5, 3))
    sentiment_label  = Column(String(20))

    headline         = Column(Text)
    url              = Column(Text)

    load_ts          = Column(DateTime)


# ── PORTFOLIO MASTER ────────────────────────────────────────────────
class Portfolio(Base):
    __tablename__ = "portfolio"
    __table_args__ = {"schema": "rankalpha"}

    portfolio_id   = Column(UUID(as_uuid=True),
                            primary_key=True,
                            default=uuid.uuid4)
    portfolio_name = Column(String(50), unique=True, nullable=False)
    currency_code  = Column(CHAR(3), nullable=False, default='USD')
    inception_date = Column(Date)
    description    = Column(Text)

    positions = relationship("PortfolioPosition",
                             back_populates="portfolio",
                             cascade="all, delete-orphan")

# ── CURRENT HOLDINGS ────────────────────────────────────────────────
class PortfolioPosition(Base):
    __tablename__ = "portfolio_position"
    __table_args__ = (
        UniqueConstraint("portfolio_id", "stock_key",
                         name="uq_portfolio_stock"),
        {"schema": "rankalpha"},
    )

    position_id    = Column(UUID(as_uuid=True),
                            primary_key=True,
                            default=uuid.uuid4)
    portfolio_id   = Column(UUID(as_uuid=True),
                            ForeignKey("rankalpha.portfolio.portfolio_id"),
                            nullable=False)
    stock_key      = Column(Integer,
                            ForeignKey("rankalpha.dim_stock.stock_key"),
                            nullable=False)
    quantity       = Column(Numeric(20, 4), nullable=False)
    avg_cost       = Column(Numeric(20, 4))
    open_date      = Column(Date)
    last_update_ts = Column(DateTime,
                            server_default=func.now(),
                            onupdate=func.now(),
                            nullable=False)

    portfolio = relationship("Portfolio", back_populates="positions")
    stock     = relationship("DimStock")

# OPTIONAL: handy read‑only mapping to the view
class VwPortfolioPosition(Base):
    __tablename__ = "vw_portfolio_position"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    position_id    = Column(UUID(as_uuid=True), primary_key=True)
    portfolio_id   = Column(UUID(as_uuid=True))
    portfolio_name = Column(String(50))
    symbol         = Column(String(20))
    company_name   = Column(Text)
    quantity       = Column(Numeric(20, 4))
    avg_cost       = Column(Numeric(20, 4))
    position_cost  = Column(Numeric(20, 4))
    open_date      = Column(Date)
    last_update_ts = Column(DateTime)

# (optional) reverse lookup on DimStock:
DimStock.positions = relationship(
    "PortfolioPosition",
    back_populates="stock",
    cascade="all, delete-orphan",
)


# ── MARKET & BENCHMARKS ───────────────────────────────────────────────
class FactSecurityPrice(Base):
    __tablename__  = "fact_security_price"
    __table_args__ = {"schema": "rankalpha"}

    date_key   = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                        primary_key=True)
    stock_key  = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"),
                        primary_key=True)

    open_px    = Column(Numeric(20, 4))
    high_px    = Column(Numeric(20, 4))
    low_px     = Column(Numeric(20, 4))
    close_px   = Column(Numeric(20, 4))
    total_return_factor = Column(Numeric(18, 8))
    volume     = Column(BigInteger)
    load_ts    = Column(DateTime, server_default=func.now(), nullable=False)

class FactCorporateAction(Base):
    __tablename__  = "fact_corporate_action"
    __table_args__ = {"schema": "rankalpha"}

    action_id   = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    stock_key   = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"),
                         nullable=False)
    action_type = Column(String(12), nullable=False)
    ex_date     = Column(Date, nullable=False)
    ratio_or_amt = Column(Numeric(18, 8))
    declared_ts = Column(DateTime, server_default=func.now(), nullable=False)

class DimBenchmark(Base):
    __tablename__  = "dim_benchmark"
    __table_args__ = {"schema": "rankalpha"}

    benchmark_key  = Column(Integer, primary_key=True)
    benchmark_name = Column(String(50), unique=True, nullable=False)
    currency_code  = Column(CHAR(3), nullable=False, default='USD')
    description    = Column(Text)

class FactBenchmarkPrice(Base):
    __tablename__  = "fact_benchmark_price"
    __table_args__ = {"schema": "rankalpha"}

    date_key      = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                            primary_key=True)
    benchmark_key = Column(Integer, ForeignKey("rankalpha.dim_benchmark.benchmark_key"),
                            primary_key=True)
    close_px      = Column(Numeric(20, 4))
    total_return_factor = Column(Numeric(18, 8))

class DimFactor(Base):
    __tablename__  = "dim_factor"
    __table_args__ = (
        UniqueConstraint("model_name", "factor_name",
                         name="uq_factor_model_name"),
        {"schema": "rankalpha"},
    )

    factor_key   = Column(Integer, primary_key=True)
    model_name   = Column(String(20), nullable=False)
    factor_name  = Column(String(40), nullable=False)
    description  = Column(Text)

class FactFactorReturn(Base):
    __tablename__  = "fact_factor_return"
    __table_args__ = {"schema": "rankalpha"}

    date_key    = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                         primary_key=True)
    factor_key  = Column(Integer, ForeignKey("rankalpha.dim_factor.factor_key"),
                         primary_key=True)
    daily_return = Column(Numeric(10, 6), nullable=False)

class FactFxRate(Base):
    __tablename__  = "fact_fx_rate"
    __table_args__ = {"schema": "rankalpha"}

    date_key  = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                       primary_key=True)
    from_ccy  = Column(CHAR(3), primary_key=True)
    to_ccy    = Column(CHAR(3), primary_key=True)
    mid_px    = Column(Numeric(18, 8), nullable=False)

# ── TRADE & PORTFOLIO TIME SERIES ─────────────────────────────────────
class FactPortfolioTrade(Base):
    __tablename__  = "fact_portfolio_trade"
    __table_args__ = {"schema": "rankalpha"}

    trade_id     = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    portfolio_id = Column(UUID(as_uuid=True),
                          ForeignKey("rankalpha.portfolio.portfolio_id"),
                          nullable=False)
    stock_key    = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"),
                          nullable=False)
    exec_ts      = Column(DateTime, nullable=False)
    side         = Column(String(4), nullable=False)   # BUY / SELL
    quantity     = Column(Numeric(20, 4), nullable=False)
    price        = Column(Numeric(20, 4), nullable=False)
    commission   = Column(Numeric(20, 4))
    venue        = Column(String(12))
    strategy_tag = Column(String(40))

class FactPortfolioPositionHist(Base):
    __tablename__  = "fact_portfolio_position_hist"
    __table_args__ = {"schema": "rankalpha"}

    effective_date = Column(Date, primary_key=True)
    portfolio_id   = Column(UUID(as_uuid=True),
                            ForeignKey("rankalpha.portfolio.portfolio_id"),
                            primary_key=True)
    stock_key      = Column(Integer,
                            ForeignKey("rankalpha.dim_stock.stock_key"),
                            primary_key=True)
    quantity       = Column(Numeric(20, 4), nullable=False)
    avg_cost       = Column(Numeric(20, 4))
    run_id         = Column(UUID(as_uuid=True), nullable=False,
                            default=uuid.uuid4)

class FactPortfolioNav(Base):
    __tablename__  = "fact_portfolio_nav"
    __table_args__ = {"schema": "rankalpha"}

    date_key     = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                          primary_key=True)
    portfolio_id = Column(UUID(as_uuid=True),
                          ForeignKey("rankalpha.portfolio.portfolio_id"),
                          primary_key=True)
    nav_base_ccy = Column(Numeric(20, 4), nullable=False)
    gross_leverage = Column(Numeric(6, 2))
    capital_inflow = Column(Numeric(20, 4))
    capital_outflow = Column(Numeric(20, 4))
    load_ts      = Column(DateTime, server_default=func.now(), nullable=False)

class FactPortfolioPnl(Base):
    __tablename__  = "fact_portfolio_pnl"
    __table_args__ = {"schema": "rankalpha"}

    date_key     = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                          primary_key=True)
    portfolio_id = Column(UUID(as_uuid=True),
                          ForeignKey("rankalpha.portfolio.portfolio_id"),
                          primary_key=True)
    unrealised_pnl  = Column(Numeric(20, 4))
    realised_pnl    = Column(Numeric(20, 4))
    dividend_income = Column(Numeric(20, 4))
    fees            = Column(Numeric(20, 4))

class FactPortfolioRisk(Base):
    __tablename__  = "fact_portfolio_risk"
    __table_args__ = {"schema": "rankalpha"}

    date_key     = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                          primary_key=True)
    portfolio_id = Column(UUID(as_uuid=True),
                          ForeignKey("rankalpha.portfolio.portfolio_id"),
                          primary_key=True)
    metric_name  = Column(String(32), primary_key=True)
    metric_value = Column(Numeric(20, 6), nullable=False)
    methodology  = Column(String(20))

# ---------- NEW DIMENSION -------------------------------------------
class DimVarMethod(Base):
    __tablename__ = "dim_var_method"
    __table_args__ = {"schema": "rankalpha"}

    var_method_key = Column(Integer, primary_key=True)
    method_label   = Column(String(30), unique=True, nullable=False)
    description    = Column(Text)

    vars = relationship("FactPortfolioVar", back_populates="method")


class DimStressScenario(Base):
    __tablename__ = "dim_stress_scenario"
    __table_args__ = {"schema": "rankalpha"}

    scenario_key   = Column(Integer, primary_key=True)
    scenario_name  = Column(String(50), unique=True, nullable=False)
    category       = Column(String(20))
    reference_date = Column(Date)
    severity_label = Column(String(12))
    description    = Column(Text)

    pnl = relationship("FactPortfolioScenarioPnl", back_populates="scenario")

# ---------- NEW FACTS -----------------------------------------------
class FactPortfolioVar(Base):
    __tablename__ = "fact_portfolio_var"
    __table_args__ = {"schema": "rankalpha"}

    date_key       = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    portfolio_id   = Column(UUID(as_uuid=True), ForeignKey("rankalpha.portfolio.portfolio_id"), primary_key=True)
    var_method_key = Column(Integer, ForeignKey("rankalpha.dim_var_method.var_method_key"), primary_key=True)
    horizon_days   = Column(Integer, primary_key=True)
    confidence_pct = Column(Numeric(5, 2), primary_key=True)
    var_value      = Column(Numeric(20, 4), nullable=False)
    es_value       = Column(Numeric(20, 4))
    load_ts        = Column(DateTime, server_default=func.now(), nullable=False)

    date      = relationship("DimDate")
    portfolio = relationship("Portfolio", back_populates="vars")
    method    = relationship("DimVarMethod", back_populates="vars")


class FactPortfolioFactorExposure(Base):
    __tablename__ = "fact_portfolio_factor_exposure"
    __table_args__ = {"schema": "rankalpha"}

    date_key     = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    portfolio_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.portfolio.portfolio_id"), primary_key=True)
    factor_key   = Column(Integer, ForeignKey("rankalpha.dim_factor.factor_key"), primary_key=True)
    exposure_value = Column(Numeric(20, 6), nullable=False)
    load_ts      = Column(DateTime, server_default=func.now(), nullable=False)

    date      = relationship("DimDate")
    portfolio = relationship("Portfolio", back_populates="factor_exposures")
    factor    = relationship("DimFactor")


class FactPortfolioScenarioPnl(Base):
    __tablename__ = "fact_portfolio_scenario_pnl"
    __table_args__ = {"schema": "rankalpha"}

    date_key     = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    portfolio_id = Column(UUID(as_uuid=True), ForeignKey("rankalpha.portfolio.portfolio_id"), primary_key=True)
    scenario_key = Column(Integer, ForeignKey("rankalpha.dim_stress_scenario.scenario_key"), primary_key=True)
    pnl_value    = Column(Numeric(20, 4), nullable=False)
    load_ts      = Column(DateTime, server_default=func.now(), nullable=False)

    date      = relationship("DimDate")
    portfolio = relationship("Portfolio", back_populates="scenario_pnls")
    scenario  = relationship("DimStressScenario", back_populates="pnl")

# ---------- BACK‑REFS ON Portfolio -----------------------------------
Portfolio.vars             = relationship("FactPortfolioVar", back_populates="portfolio",
                                           cascade="all, delete-orphan")
Portfolio.factor_exposures = relationship("FactPortfolioFactorExposure",
                                           back_populates="portfolio",
                                           cascade="all, delete-orphan")
Portfolio.scenario_pnls    = relationship("FactPortfolioScenarioPnl",
                                           back_populates="portfolio",
                                           cascade="all, delete-orphan")
# ---------- READ‑ONLY RISK VIEWS ------------------------------------
class VwPortfolioVar(Base):
    __tablename__   = "vw_portfolio_var"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    risk_date      = Column(Date,      primary_key=True)
    portfolio_name = Column(String(50), primary_key=True)
    method_label   = Column(String(30), primary_key=True)
    horizon_days   = Column(Integer,   primary_key=True)
    confidence_pct = Column(Numeric(5, 2), primary_key=True)

    var_value  = Column(Numeric(20, 4))
    es_value   = Column(Numeric(20, 4))
    load_ts    = Column(DateTime)


class VwPortfolioFactorExposure(Base):
    __tablename__   = "vw_portfolio_factor_exposure"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    exposure_date   = Column(Date,       primary_key=True)
    portfolio_name  = Column(String(50), primary_key=True)
    model_name      = Column(String(20), primary_key=True)
    factor_name     = Column(String(40), primary_key=True)

    exposure_value  = Column(Numeric(20, 6))
    load_ts         = Column(DateTime)


class VwPortfolioScenarioPnl(Base):
    __tablename__   = "vw_portfolio_scenario_pnl"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    scenario_date   = Column(Date,       primary_key=True)
    portfolio_name  = Column(String(50), primary_key=True)
    scenario_name   = Column(String(50), primary_key=True)

    category        = Column(String(20))
    severity_label  = Column(String(12))
    pnl_value       = Column(Numeric(20, 4))
    load_ts         = Column(DateTime)

# ── MARKET REFERENCE DATA ────────────────────────────────────────────
class DimTenor(Base):
    __tablename__ = "dim_tenor"
    __table_args__ = {"schema": "rankalpha"}

    tenor_key   = Column(Integer, primary_key=True)
    tenor_label = Column(String(10), unique=True, nullable=False)
    tenor_days  = Column(SmallInteger, nullable=False)

# Risk‑free
class FactRiskFreeRate(Base):
    __tablename__ = "fact_risk_free_rate"
    __table_args__ = {"schema": "rankalpha"}

    date_key  = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                       primary_key=True)
    tenor_key = Column(Integer, ForeignKey("rankalpha.dim_tenor.tenor_key"),
                       primary_key=True)
    rate_pct  = Column(Numeric(10, 4), nullable=False)
    load_ts   = Column(DateTime, server_default=func.now(), nullable=False)

# Borrow cost
class FactStockBorrowRate(Base):
    __tablename__ = "fact_stock_borrow_rate"
    __table_args__ = {"schema": "rankalpha"}

    date_key       = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                             primary_key=True)
    stock_key      = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"),
                             primary_key=True)
    borrow_rate_bp = Column(Numeric(12, 4), nullable=False)   # basis‑points
    load_ts        = Column(DateTime, server_default=func.now(), nullable=False)

# Implied volatility
class FactIvSurface(Base):
    __tablename__ = "fact_iv_surface"
    __table_args__ = {"schema": "rankalpha"}

    date_key    = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"),
                          primary_key=True)
    stock_key   = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"),
                          primary_key=True)
    tenor_key   = Column(Integer, ForeignKey("rankalpha.dim_tenor.tenor_key"),
                          primary_key=True)
    implied_vol = Column(Numeric(8, 4), nullable=False)
    load_ts     = Column(DateTime, server_default=func.now(), nullable=False)

# Read‑only views ------------------------------------------------------
class VwRiskFreeRate(Base):
    __tablename__   = "vw_risk_free_rate"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    rate_date   = Column(Date, primary_key=True)
    tenor_label = Column(String(10), primary_key=True)
    rate_pct    = Column(Numeric(10, 4))

# ---------- AI ANALYSIS FULL VIEW (denormalized) --------------------
class VwAiAnalysisFull(Base):
    __tablename__   = "vw_ai_analysis_full"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    analysis_id = Column(UUID(as_uuid=True), primary_key=True)
    date_key = Column(Integer)
    as_of_date = Column(Date)
    symbol = Column(String(20))
    company_name = Column(Text)
    asset_type = Column(String(20))
    source_name = Column(String(50))

    market_cap_usd = Column(Numeric(20, 2))
    revenue_cagr_3y_pct = Column(Numeric(6, 2))
    gross_margin_trend = Column(String(20))
    net_margin_trend = Column(String(20))
    free_cash_flow_trend = Column(String(20))
    insider_activity = Column(String(20))

    beta_sp500 = Column(Numeric(6, 4))
    rate_sensitivity_bps = Column(Numeric(10, 2))
    fx_sensitivity = Column(String(8))
    commodity_exposure = Column(String(8))

    news_sentiment_30d = Column(Numeric(5, 2))
    social_sentiment_7d = Column(Numeric(5, 2))
    options_skew_30d = Column(Numeric(7, 3))
    short_interest_pct_float = Column(Numeric(6, 2))
    employee_glassdoor_score = Column(Numeric(4, 2))
    headline_buzz_score = Column(String(6))
    commentary = Column(Text)

    overall_rating = Column(String(20))
    confidence = Column(String(10))
    recommendation_timeframe = Column(String(12))

    pe_forward = Column(Numeric(10, 2))
    ev_ebitda_forward = Column(Numeric(10, 2))
    pe_percentile_in_sector = Column(Numeric(6, 2))

    value_score = Column(Numeric(5, 2))
    quality_score = Column(Numeric(5, 2))
    momentum_score = Column(Numeric(5, 2))
    low_vol_score = Column(Numeric(5, 2))

    bull_price_target = Column(Numeric(20, 2))
    bull_probability_pct = Column(Numeric(6, 2))
    base_price_target = Column(Numeric(20, 2))
    base_probability_pct = Column(Numeric(6, 2))
    bear_price_target = Column(Numeric(20, 2))
    bear_probability_pct = Column(Numeric(6, 2))

    short_catalysts = Column(JSONB)
    long_catalysts = Column(JSONB)
    macro_risks = Column(ARRAY(Text))
    headline_risks = Column(ARRAY(Text))
    data_gaps = Column(ARRAY(Text))
    peers = Column(JSONB)
    load_ts = Column(DateTime)

class VwStockBorrowRate(Base):
    __tablename__   = "vw_stock_borrow_rate"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    borrow_date = Column(Date, primary_key=True)
    symbol      = Column(String(20), primary_key=True)
    borrow_rate_bp = Column(Numeric(12, 4))

class VwIvSurface(Base):
    __tablename__   = "vw_iv_surface"
    __table_args__  = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    iv_date     = Column(Date, primary_key=True)
    symbol      = Column(String(20), primary_key=True)
    tenor_label = Column(String(10), primary_key=True)
    implied_vol = Column(Numeric(8, 4))


class VLatestScreener(Base):
    __tablename__ = "v_latest_screener"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key       = Column(Integer, primary_key=True)
    fact_id        = Column(UUID(as_uuid=True))
    stock_key      = Column(Integer)
    source_key     = Column(Integer)
    style_key      = Column(Integer)
    rank_value     = Column(Integer)
    appearances   = Column(Integer)
    screening_runid = Column(UUID(as_uuid=True))
    load_ts        = Column(DateTime)

class VLatestScreenerValues(Base):
    __tablename__ = "v_latest_screener_values"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key     = Column(Integer, primary_key=True)
    full_date    = Column(Date)
    symbol       = Column(String(20))
    company_name = Column(Text)
    sector       = Column(Text)
    exchange     = Column(Text)
    source       = Column(String(50))
    style        = Column(String(50))
    rank_value   = Column(Integer)
    screening_runid = Column(UUID(as_uuid=True))
    load_ts      = Column(DateTime)

class VLatestScreenerConsensus(Base):
    __tablename__ = "v_latest_screener_consensus"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    full_date    = Column(Date, primary_key=True)
    symbol       = Column(String(20), primary_key=True)
    company_name = Column(Text)
    sector       = Column(Text)
    exchange     = Column(Text)
    primary_source = Column(String(50))
    primary_style  = Column(String(50))

    rank_best    = Column(Integer)
    rank_avg     = Column(Numeric(10,2))
    rank_median  = Column(Numeric(10,2))
    appearances  = Column(Integer)
    styles_distinct  = Column(Integer)
    sources_distinct = Column(Integer)
    styles       = Column(ARRAY(String))
    sources      = Column(ARRAY(String))
    runids       = Column(ARRAY(UUID(as_uuid=True)))
    min_style_rank_pct = Column(Numeric(8,6))
    consensus_score    = Column(Numeric(6,2))

class FactTechnicalIndicator(Base):
    __tablename__ = "fact_technical_indicator"
    __table_args__ = {"schema": "rankalpha"}

    date_key = Column(Integer, ForeignKey("rankalpha.dim_date.date_key"), primary_key=True)
    stock_key = Column(Integer, ForeignKey("rankalpha.dim_stock.stock_key"), primary_key=True)
    indicator_code = Column(String(40), primary_key=True)
    value = Column(Numeric(20, 6))
    load_ts = Column(DateTime, server_default=func.now(), nullable=False)

class VwLatestTechnicals(Base):
    __tablename__ = "vw_latest_technicals"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    as_of_date = Column(Date, primary_key=True)
    symbol = Column(String(20), primary_key=True)
    company_name = Column(Text)
    sma20 = Column(Numeric(20, 6))
    sma50 = Column(Numeric(20, 6))
    sma200 = Column(Numeric(20, 6))
    ema12 = Column(Numeric(20, 6))
    ema26 = Column(Numeric(20, 6))
    rsi14 = Column(Numeric(20, 6))
    atr14 = Column(Numeric(20, 6))
    bb_upper = Column(Numeric(20, 6))
    bb_middle = Column(Numeric(20, 6))
    bb_lower = Column(Numeric(20, 6))
    macd = Column(Numeric(20, 6))
    macd_signal = Column(Numeric(20, 6))
    macd_hist = Column(Numeric(20, 6))
    ret_5d = Column(Numeric(20, 6))
    ret_20d = Column(Numeric(20, 6))
    ret_60d = Column(Numeric(20, 6))
    ret_120d = Column(Numeric(20, 6))
    vol_z20 = Column(Numeric(20, 6))
    dist_52w_high = Column(Numeric(20, 6))

class VwFinFundamentals(Base):
    __tablename__ = "vw_fin_fundamentals"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key     = Column(Integer, primary_key=True)
    as_of_date   = Column(Date)
    symbol       = Column(String(20))
    company_name = Column(Text)
    metric_code  = Column(String(60))
    metric_name  = Column(Text)
    fiscal_year  = Column(SmallInteger)
    fiscal_period = Column(String(3))
    metric_value = Column(Numeric(20, 4))
    source_name  = Column(String(50))
    load_ts      = Column(DateTime)

class VwPortfolioPerformance(Base):
    __tablename__ = "vw_portfolio_performance"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key    = Column(Integer, primary_key=True)
    full_date   = Column(Date)
    portfolio_id = Column(UUID(as_uuid=True))
    portfolio_name = Column(String(50))
    nav_base_ccy = Column(Numeric(20, 4))
    nav_prev    = Column(Numeric(20, 4))
    daily_return = Column(Numeric(12, 6))

class VwPortfolioSnapshot(Base):
    __tablename__ = "vw_portfolio_snapshot"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    portfolio_id   = Column(UUID(as_uuid=True), primary_key=True)
    portfolio_name = Column(String(50))
    symbol         = Column(String(20))
    company_name   = Column(Text)
    quantity       = Column(Numeric(20, 4))
    avg_cost       = Column(Numeric(20, 4))
    last_close     = Column(Numeric(20, 4))
    market_value   = Column(Numeric(20, 4))
    nav            = Column(Numeric(20, 4))
    weight_pct     = Column(Numeric(8, 6))
    last_update_ts = Column(DateTime)

class VwPortfolioTopContrib(Base):
    __tablename__ = "vw_portfolio_top_contrib"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    portfolio_id   = Column(UUID(as_uuid=True), primary_key=True)
    portfolio_name = Column(String(50))
    symbol         = Column(String(20))
    company_name   = Column(Text)
    quantity       = Column(Numeric(20, 4))
    close_px       = Column(Numeric(20, 4))
    unreal_pnl     = Column(Numeric(20, 4))

class VwPortfolioTurnover(Base):
    __tablename__ = "vw_portfolio_turnover"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    full_date        = Column(Date, primary_key=True)
    portfolio_id     = Column(UUID(as_uuid=True))
    portfolio_name   = Column(String(50))
    notional_traded  = Column(Numeric(20, 4))
    nav_base_ccy     = Column(Numeric(20, 4))
    turnover_pct     = Column(Numeric(10, 6))

class VwRiskDashboard(Base):
    __tablename__ = "vw_risk_dashboard"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key     = Column(Integer, primary_key=True)
    full_date    = Column(Date)
    portfolio_name = Column(String(50))
    var_95_1d    = Column(Numeric(20, 4))
    beta_spx     = Column(Numeric(12, 6))
    liq_days     = Column(Numeric(12, 6))

class VwScoreHistory(Base):
    __tablename__ = "vw_score_history"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key     = Column(Integer, primary_key=True)
    as_of_date   = Column(Date)
    symbol       = Column(String(20))
    score_type_name = Column(String(50))
    score        = Column(Numeric(10, 2))
    source_name  = Column(String(50))
    load_ts      = Column(DateTime)

class VwScreenerRank(Base):
    __tablename__ = "vw_screener_rank"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key     = Column(Integer, primary_key=True)
    as_of_date   = Column(Date)
    symbol       = Column(String(20))
    style_name   = Column(String(50))
    rank_value   = Column(Integer)
    screening_runid = Column(UUID(as_uuid=True))
    load_ts      = Column(DateTime)
    source_name  = Column(String(50))

class VwStockStyleScores(Base):
    __tablename__ = "vw_stock_style_scores"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    date_key     = Column(Integer, primary_key=True)
    as_of_date   = Column(Date)
    symbol       = Column(String(20))
    style_name   = Column(String(50))
    score_value  = Column(Numeric(5, 2))
    rank_value   = Column(Integer)
    score_runid  = Column(UUID(as_uuid=True))
    load_ts      = Column(DateTime)


class MvLatestGrades(Base):
    __tablename__ = "mv_latest_grades"
    __table_args__ = {"schema": "rankalpha"}
    __mapper_args__ = {"eager_defaults": False}

    as_of_date      = Column(Date)
    symbol          = Column(String(20), primary_key=True)
    company_name    = Column(Text)
    sector          = Column(Text)
    exchange        = Column(Text)
    momentum_score  = Column(Numeric(10, 2))
    value_score     = Column(Numeric(10, 2))
    sentiment_score = Column(Numeric(10, 2))
    avg_score       = Column(Numeric(10, 2))
    grade           = Column(String(2))
    grade_order     = Column(Integer)
