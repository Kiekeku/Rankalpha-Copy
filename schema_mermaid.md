```mermaid
erDiagram
    dim_date {
        INT date_key PK
        DATE full_date
    }
    dim_stock {
        INT stock_key PK
        VARCHAR symbol
        TEXT company_name
    }
    dim_source {
        INT source_key PK
        VARCHAR source_name
    }
    dim_style {
        INT style_key PK
        VARCHAR style_name
    }
    dim_score_type {
        INT score_type_key PK
        VARCHAR score_type_name
    }
    dim_corr_method {
        INT corr_method_key PK
    }
    dim_corr_window {
        INT corr_window_key PK
    }
    dim_fin_metric {
        INT metric_key PK
        VARCHAR metric_code
    }
    fact_screener_rank {
        INT date_key FK
        INT stock_key FK
        INT source_key FK
        INT style_key FK
        INT rank_value
    }
    fact_stock_scores {
        INT date_key FK
        INT stock_key FK
        INT style_key FK
        DECIMAL score_value
        INT rank_value
    }
    fact_stock_score_types {
        INT date_key FK
        INT stock_key FK
        INT score_type_key FK
        DECIMAL score_value
        INT rank_value
    }
    fact_score_history {
        INT date_key FK
        INT stock_key FK
        INT source_key FK
        INT score_type_key FK
        DECIMAL score
    }
    fact_news_articles {
        INT article_date FK
        INT stock_key FK
        INT source_key FK
        TEXT headline
    }
    fact_news_sentiment {
        UUID article_id FK
        DECIMAL sentiment_score
    }
    fact_stock_correlation {
        INT date_key FK
        INT stock1_key FK
        INT stock2_key FK
        INT corr_method_key FK
        INT corr_window_key FK
        NUMERIC correlation_value
    }
    fact_fin_fundamentals {
        INT date_key FK
        INT stock_key FK
        INT source_key FK
        INT metric_key FK
        NUMERIC metric_value
    }

    dim_date ||--o{ fact_screener_rank : date
    dim_stock ||--o{ fact_screener_rank : stock
    dim_source ||--o{ fact_screener_rank : source
    dim_style ||--o{ fact_screener_rank : style
    dim_date ||--o{ fact_stock_scores : date
    dim_stock ||--o{ fact_stock_scores : stock
    dim_style ||--o{ fact_stock_scores : style
    dim_date ||--o{ fact_stock_score_types : date
    dim_stock ||--o{ fact_stock_score_types : stock
    dim_score_type ||--o{ fact_stock_score_types : score_type
    dim_date ||--o{ fact_score_history : date
    dim_stock ||--o{ fact_score_history : stock
    dim_source ||--o{ fact_score_history : source
    dim_score_type ||--o{ fact_score_history : score_type
    dim_stock ||--o{ fact_news_articles : stock
    dim_source ||--o{ fact_news_articles : source
    dim_date ||--o{ fact_news_articles : article_date
    fact_news_articles ||--|| fact_news_sentiment : article
    dim_date ||--o{ fact_stock_correlation : date
    dim_stock ||--o{ fact_stock_correlation : stock1
    dim_stock ||--o{ fact_stock_correlation : stock2
    dim_corr_method ||--o{ fact_stock_correlation : method
    dim_corr_window ||--o{ fact_stock_correlation : window
    dim_date ||--o{ fact_fin_fundamentals : date
    dim_stock ||--o{ fact_fin_fundamentals : stock
    dim_source ||--o{ fact_fin_fundamentals : source
    dim_fin_metric ||--o{ fact_fin_fundamentals : metric
```
