-- rankalpha.dim_asset_type definition

-- Drop table

-- DROP TABLE rankalpha.dim_asset_type;

CREATE TABLE rankalpha.dim_asset_type (
	asset_type_key serial4 NOT NULL,
	asset_type_name varchar(20) NOT NULL,
	CONSTRAINT dim_asset_type_asset_type_name_key UNIQUE (asset_type_name),
	CONSTRAINT dim_asset_type_pkey PRIMARY KEY (asset_type_key)
);


-- rankalpha.dim_benchmark definition

-- Drop table

-- DROP TABLE rankalpha.dim_benchmark;

CREATE TABLE rankalpha.dim_benchmark (
	benchmark_key serial4 NOT NULL,
	benchmark_name varchar(50) NOT NULL,
	currency_code bpchar(3) DEFAULT 'USD'::bpchar NOT NULL,
	description text NULL,
	CONSTRAINT dim_benchmark_benchmark_name_key UNIQUE (benchmark_name),
	CONSTRAINT dim_benchmark_pkey PRIMARY KEY (benchmark_key)
);


-- rankalpha.dim_confidence definition

-- Drop table

-- DROP TABLE rankalpha.dim_confidence;

CREATE TABLE rankalpha.dim_confidence (
	confidence_key serial4 NOT NULL,
	confidence_label varchar(10) NOT NULL,
	CONSTRAINT dim_confidence_confidence_label_key UNIQUE (confidence_label),
	CONSTRAINT dim_confidence_pkey PRIMARY KEY (confidence_key)
);


-- rankalpha.dim_corr_method definition

-- Drop table

-- DROP TABLE rankalpha.dim_corr_method;

CREATE TABLE rankalpha.dim_corr_method (
	corr_method_key serial4 NOT NULL,
	corr_method_name varchar(40) NOT NULL,
	CONSTRAINT dim_corr_method_corr_method_name_key UNIQUE (corr_method_name),
	CONSTRAINT dim_corr_method_pkey PRIMARY KEY (corr_method_key)
);


-- rankalpha.dim_corr_window definition

-- Drop table

-- DROP TABLE rankalpha.dim_corr_window;

CREATE TABLE rankalpha.dim_corr_window (
	corr_window_key serial4 NOT NULL,
	window_label varchar(30) NOT NULL,
	window_days int2 NOT NULL,
	CONSTRAINT dim_corr_window_pkey PRIMARY KEY (corr_window_key),
	CONSTRAINT dim_corr_window_window_label_key UNIQUE (window_label)
);


-- rankalpha.dim_date definition

-- Drop table

-- DROP TABLE rankalpha.dim_date;

CREATE TABLE rankalpha.dim_date (
	date_key int4 NOT NULL,
	full_date date NOT NULL,
	day_of_week int2 NOT NULL,
	month_num int2 NOT NULL,
	month_name varchar(10) NOT NULL,
	quarter int2 NOT NULL,
	calendar_year int2 NOT NULL,
	is_trading_day bool DEFAULT true NOT NULL,
	CONSTRAINT dim_date_full_date_key UNIQUE (full_date),
	CONSTRAINT dim_date_pkey PRIMARY KEY (date_key)
);


-- rankalpha.dim_factor definition

-- Drop table

-- DROP TABLE rankalpha.dim_factor;

CREATE TABLE rankalpha.dim_factor (
	factor_key serial4 NOT NULL,
	model_name varchar(20) NOT NULL,
	factor_name varchar(40) NOT NULL,
	description text NULL,
	CONSTRAINT dim_factor_model_name_factor_name_key UNIQUE (model_name, factor_name),
	CONSTRAINT dim_factor_pkey PRIMARY KEY (factor_key)
);


-- rankalpha.dim_fin_metric definition

-- Drop table

-- DROP TABLE rankalpha.dim_fin_metric;

CREATE TABLE rankalpha.dim_fin_metric (
	metric_key serial4 NOT NULL,
	metric_code varchar(60) NOT NULL,
	metric_name text NOT NULL,
	stmt_code varchar(64) NOT NULL,
	default_unit varchar(64) DEFAULT 'USD'::character varying NULL,
	CONSTRAINT dim_fin_metric_metric_code_key UNIQUE (metric_code),
	CONSTRAINT dim_fin_metric_pkey PRIMARY KEY (metric_key)
);


-- rankalpha.dim_rating definition

-- Drop table

-- DROP TABLE rankalpha.dim_rating;

CREATE TABLE rankalpha.dim_rating (
	rating_key serial4 NOT NULL,
	rating_label varchar(20) NOT NULL,
	CONSTRAINT dim_rating_pkey PRIMARY KEY (rating_key),
	CONSTRAINT dim_rating_rating_label_key UNIQUE (rating_label)
);


-- rankalpha.dim_score_type definition

-- Drop table

-- DROP TABLE rankalpha.dim_score_type;

CREATE TABLE rankalpha.dim_score_type (
	score_type_key serial4 NOT NULL,
	score_type_name varchar(50) NOT NULL,
	CONSTRAINT dim_score_type_pkey PRIMARY KEY (score_type_key),
	CONSTRAINT dim_score_type_score_type_name_key UNIQUE (score_type_name)
);


-- rankalpha.dim_source definition

-- Drop table

-- DROP TABLE rankalpha.dim_source;

CREATE TABLE rankalpha.dim_source (
	source_key serial4 NOT NULL,
	source_name varchar(50) NOT NULL,
	"version" varchar(20) DEFAULT '1'::character varying NOT NULL,
	CONSTRAINT dim_source_pkey PRIMARY KEY (source_key),
	CONSTRAINT dim_source_source_name_key UNIQUE (source_name),
	CONSTRAINT dim_source_source_name_version_uc UNIQUE (source_name, version)
);
CREATE UNIQUE INDEX dim_source_source_name_version_uidx ON rankalpha.dim_source USING btree (source_name, version);


-- rankalpha.dim_stress_scenario definition

-- Drop table

-- DROP TABLE rankalpha.dim_stress_scenario;

CREATE TABLE rankalpha.dim_stress_scenario (
	scenario_key serial4 NOT NULL,
	scenario_name varchar(50) NOT NULL,
	category varchar(20) NULL,
	reference_date date NULL,
	severity_label varchar(12) NULL,
	description text NULL,
	CONSTRAINT dim_stress_scenario_pkey PRIMARY KEY (scenario_key),
	CONSTRAINT dim_stress_scenario_scenario_name_key UNIQUE (scenario_name)
);


-- rankalpha.dim_style definition

-- Drop table

-- DROP TABLE rankalpha.dim_style;

CREATE TABLE rankalpha.dim_style (
	style_key serial4 NOT NULL,
	style_name varchar(50) NOT NULL,
	CONSTRAINT dim_style_pkey PRIMARY KEY (style_key),
	CONSTRAINT dim_style_style_name_key UNIQUE (style_name)
);


-- rankalpha.dim_tenor definition

-- Drop table

-- DROP TABLE rankalpha.dim_tenor;

CREATE TABLE rankalpha.dim_tenor (
	tenor_key serial4 NOT NULL,
	tenor_label varchar(10) NOT NULL,
	tenor_days int2 NOT NULL,
	CONSTRAINT dim_tenor_pkey PRIMARY KEY (tenor_key),
	CONSTRAINT dim_tenor_tenor_label_key UNIQUE (tenor_label)
);


-- rankalpha.dim_timeframe definition

-- Drop table

-- DROP TABLE rankalpha.dim_timeframe;

CREATE TABLE rankalpha.dim_timeframe (
	timeframe_key serial4 NOT NULL,
	timeframe_label varchar(12) NOT NULL,
	CONSTRAINT dim_timeframe_pkey PRIMARY KEY (timeframe_key),
	CONSTRAINT dim_timeframe_timeframe_label_key UNIQUE (timeframe_label)
);


-- rankalpha.dim_trend_category definition

-- Drop table

-- DROP TABLE rankalpha.dim_trend_category;

CREATE TABLE rankalpha.dim_trend_category (
	trend_key serial4 NOT NULL,
	trend_label varchar(20) NOT NULL,
	CONSTRAINT dim_trend_category_pkey PRIMARY KEY (trend_key),
	CONSTRAINT dim_trend_category_trend_label_key UNIQUE (trend_label)
);


-- rankalpha.dim_var_method definition

-- Drop table

-- DROP TABLE rankalpha.dim_var_method;

CREATE TABLE rankalpha.dim_var_method (
	var_method_key serial4 NOT NULL,
	method_label varchar(30) NOT NULL,
	description text NULL,
	CONSTRAINT dim_var_method_method_label_key UNIQUE (method_label),
	CONSTRAINT dim_var_method_pkey PRIMARY KEY (var_method_key)
);


-- rankalpha.fact_ai_catalyst definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_catalyst;

CREATE TABLE rankalpha.fact_ai_catalyst (
	catalyst_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	analysis_id uuid NOT NULL,
	catalyst_type varchar(10) NOT NULL,
	title text NOT NULL,
	description text NULL,
	probability_pct numeric(6, 2) NULL,
	expected_price_move_pct numeric(7, 2) NULL,
	expected_date date NULL,
	priced_in_pct numeric(6, 2) NULL,
	price_drop_risk_pct numeric(7, 2) NULL,
	CONSTRAINT fact_ai_catalyst_pkey PRIMARY KEY (catalyst_id)
);
CREATE INDEX idx_ai_catalyst_type_date ON rankalpha.fact_ai_catalyst USING btree (analysis_id, catalyst_type, expected_date);


-- rankalpha.fact_ai_data_gap definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_data_gap;

CREATE TABLE rankalpha.fact_ai_data_gap (
	analysis_id uuid NOT NULL,
	gap_text text NOT NULL,
	CONSTRAINT fact_ai_data_gap_pkey PRIMARY KEY (analysis_id, gap_text)
);
CREATE INDEX idx_ai_data_gap_analysis ON rankalpha.fact_ai_data_gap USING btree (analysis_id);


-- rankalpha.fact_ai_headline_risk definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_headline_risk;

CREATE TABLE rankalpha.fact_ai_headline_risk (
	analysis_id uuid NOT NULL,
	risk_text text NOT NULL,
	CONSTRAINT fact_ai_headline_risk_pkey PRIMARY KEY (analysis_id, risk_text)
);
CREATE INDEX idx_ai_headline_risk_analysis ON rankalpha.fact_ai_headline_risk USING btree (analysis_id);


-- rankalpha.fact_ai_macro_risk definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_macro_risk;

CREATE TABLE rankalpha.fact_ai_macro_risk (
	analysis_id uuid NOT NULL,
	risk_text text NOT NULL,
	CONSTRAINT fact_ai_macro_risk_pkey PRIMARY KEY (analysis_id, risk_text)
);
CREATE INDEX idx_ai_macro_risk_analysis ON rankalpha.fact_ai_macro_risk USING btree (analysis_id);


-- rankalpha.fact_ai_price_scenario definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_price_scenario;

CREATE TABLE rankalpha.fact_ai_price_scenario (
	analysis_id uuid NOT NULL,
	scenario_type varchar(6) NOT NULL,
	price_target numeric(20, 2) NULL,
	probability_pct numeric(6, 2) NULL,
	CONSTRAINT fact_ai_price_scenario_pkey PRIMARY KEY (analysis_id, scenario_type)
);
CREATE INDEX idx_ai_price_scenario_type ON rankalpha.fact_ai_price_scenario USING btree (analysis_id, scenario_type);


-- rankalpha.fact_ai_valuation_metrics definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_valuation_metrics;

CREATE TABLE rankalpha.fact_ai_valuation_metrics (
	analysis_id uuid NOT NULL,
	pe_forward numeric(10, 2) NULL,
	ev_ebitda_forward numeric(10, 2) NULL,
	pe_percentile_in_sector numeric(6, 2) NULL,
	CONSTRAINT fact_ai_valuation_metrics_pkey PRIMARY KEY (analysis_id)
);
CREATE INDEX idx_ai_val_metrics_analysis ON rankalpha.fact_ai_valuation_metrics USING btree (analysis_id);


-- rankalpha.fact_news_sentiment definition

-- Drop table

-- DROP TABLE rankalpha.fact_news_sentiment;

CREATE TABLE rankalpha.fact_news_sentiment (
	article_id uuid NOT NULL,
	sentiment_score numeric(5, 3) NOT NULL,
	sentiment_label varchar(20) NOT NULL,
	analysis_runid uuid NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_news_sentiment_pkey PRIMARY KEY (article_id)
);
CREATE INDEX idx_fact_news_sentiment_score ON rankalpha.fact_news_sentiment USING btree (sentiment_score);


-- rankalpha.flyway_schema_history definition

-- Drop table

-- DROP TABLE rankalpha.flyway_schema_history;

CREATE TABLE rankalpha.flyway_schema_history (
	installed_rank int4 NOT NULL,
	"version" varchar(50) NULL,
	description varchar(200) NOT NULL,
	"type" varchar(20) NOT NULL,
	script varchar(1000) NOT NULL,
	checksum int4 NULL,
	installed_by varchar(100) NOT NULL,
	installed_on timestamp DEFAULT now() NOT NULL,
	execution_time int4 NOT NULL,
	success bool NOT NULL,
	CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank)
);
CREATE INDEX flyway_schema_history_s_idx ON rankalpha.flyway_schema_history USING btree (success);


-- rankalpha.portfolio definition

-- Drop table

-- DROP TABLE rankalpha.portfolio;

CREATE TABLE rankalpha.portfolio (
	portfolio_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	portfolio_name varchar(50) NOT NULL,
	currency_code bpchar(3) DEFAULT 'USD'::bpchar NOT NULL,
	inception_date date NULL,
	description text NULL,
	CONSTRAINT portfolio_pkey PRIMARY KEY (portfolio_id),
	CONSTRAINT uq_portfolio_name UNIQUE (portfolio_name)
);


-- rankalpha.dim_stock definition

-- Drop table

-- DROP TABLE rankalpha.dim_stock;

CREATE TABLE rankalpha.dim_stock (
	stock_key serial4 NOT NULL,
	symbol varchar(20) NOT NULL,
	company_name text NULL,
	sector text NULL,
	exchange text NULL,
	asset_type_key int4 NULL,
	CONSTRAINT dim_stock_pkey PRIMARY KEY (stock_key),
	CONSTRAINT dim_stock_symbol_key UNIQUE (symbol),
	CONSTRAINT fk_dim_stock_asset_type FOREIGN KEY (asset_type_key) REFERENCES rankalpha.dim_asset_type(asset_type_key)
);


-- rankalpha.fact_ai_factor_score definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_factor_score;

CREATE TABLE rankalpha.fact_ai_factor_score (
	analysis_id uuid NOT NULL,
	style_key int4 NOT NULL,
	score numeric(5, 2) NOT NULL,
	CONSTRAINT fact_ai_factor_score_pkey PRIMARY KEY (analysis_id, style_key),
	CONSTRAINT fact_ai_factor_score_style_key_fkey FOREIGN KEY (style_key) REFERENCES rankalpha.dim_style(style_key)
);
CREATE INDEX idx_ai_factor_score ON rankalpha.fact_ai_factor_score USING btree (analysis_id, style_key);


-- rankalpha.fact_ai_peer_comparison definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_peer_comparison;

CREATE TABLE rankalpha.fact_ai_peer_comparison (
	analysis_id uuid NOT NULL,
	peer_stock_key int4 NOT NULL,
	pe_forward numeric(10, 2) NULL,
	ev_ebitda_forward numeric(10, 2) NULL,
	return_1y_pct numeric(7, 2) NULL,
	summary text NULL,
	CONSTRAINT fact_ai_peer_comparison_pkey PRIMARY KEY (analysis_id, peer_stock_key),
	CONSTRAINT fact_ai_peer_comparison_peer_stock_key_fkey FOREIGN KEY (peer_stock_key) REFERENCES rankalpha.dim_stock(stock_key)
);
CREATE INDEX idx_ai_peer_analysis_pair ON rankalpha.fact_ai_peer_comparison USING btree (analysis_id, peer_stock_key);


-- rankalpha.fact_ai_stock_analysis definition

-- Drop table

-- DROP TABLE rankalpha.fact_ai_stock_analysis;

CREATE TABLE rankalpha.fact_ai_stock_analysis (
	date_key int4 NOT NULL,
	analysis_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock_key int4 NOT NULL,
	source_key int4 NOT NULL,
	market_cap_usd numeric(20, 2) NULL,
	revenue_cagr_3y_pct numeric(6, 2) NULL,
	gross_margin_trend_key int4 NULL,
	net_margin_trend_key int4 NULL,
	free_cash_flow_trend_key int4 NULL,
	insider_activity_key int4 NULL,
	beta_sp500 numeric(6, 4) NULL,
	rate_sensitivity_bps numeric(10, 2) NULL,
	fx_sensitivity varchar(8) NULL,
	commodity_exposure varchar(8) NULL,
	news_sentiment_30d numeric(5, 2) NULL,
	social_sentiment_7d numeric(5, 2) NULL,
	options_skew_30d numeric(7, 3) NULL,
	short_interest_pct_float numeric(6, 2) NULL,
	employee_glassdoor_score numeric(4, 2) NULL,
	headline_buzz_score varchar(6) NULL,
	commentary text NULL,
	overall_rating_key int4 NULL,
	confidence_key int4 NULL,
	timeframe_key int4 NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_ai_stock_analysis_pkey PRIMARY KEY (date_key, analysis_id),
	CONSTRAINT fact_ai_stock_analysis_confidence_key_fkey FOREIGN KEY (confidence_key) REFERENCES rankalpha.dim_confidence(confidence_key),
	CONSTRAINT fact_ai_stock_analysis_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_ai_stock_analysis_free_cash_flow_trend_key_fkey FOREIGN KEY (free_cash_flow_trend_key) REFERENCES rankalpha.dim_trend_category(trend_key),
	CONSTRAINT fact_ai_stock_analysis_gross_margin_trend_key_fkey FOREIGN KEY (gross_margin_trend_key) REFERENCES rankalpha.dim_trend_category(trend_key),
	CONSTRAINT fact_ai_stock_analysis_insider_activity_key_fkey FOREIGN KEY (insider_activity_key) REFERENCES rankalpha.dim_trend_category(trend_key),
	CONSTRAINT fact_ai_stock_analysis_net_margin_trend_key_fkey FOREIGN KEY (net_margin_trend_key) REFERENCES rankalpha.dim_trend_category(trend_key),
	CONSTRAINT fact_ai_stock_analysis_overall_rating_key_fkey FOREIGN KEY (overall_rating_key) REFERENCES rankalpha.dim_rating(rating_key),
	CONSTRAINT fact_ai_stock_analysis_source_key_fkey FOREIGN KEY (source_key) REFERENCES rankalpha.dim_source(source_key),
	CONSTRAINT fact_ai_stock_analysis_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key),
	CONSTRAINT fact_ai_stock_analysis_timeframe_key_fkey FOREIGN KEY (timeframe_key) REFERENCES rankalpha.dim_timeframe(timeframe_key)
)
PARTITION BY RANGE (date_key);
CREATE INDEX idx_ai_stock_analysis_rating_conf ON ONLY rankalpha.fact_ai_stock_analysis USING btree (overall_rating_key, confidence_key);
CREATE INDEX idx_ai_stock_analysis_stock_date ON ONLY rankalpha.fact_ai_stock_analysis USING btree (stock_key, date_key);


-- rankalpha.fact_benchmark_price definition

-- Drop table

-- DROP TABLE rankalpha.fact_benchmark_price;

CREATE TABLE rankalpha.fact_benchmark_price (
	date_key int4 NOT NULL,
	benchmark_key int4 NOT NULL,
	close_px numeric(20, 4) NULL,
	total_return_factor numeric(18, 8) NULL,
	CONSTRAINT fact_benchmark_price_pkey PRIMARY KEY (date_key, benchmark_key),
	CONSTRAINT fact_benchmark_price_benchmark_key_fkey FOREIGN KEY (benchmark_key) REFERENCES rankalpha.dim_benchmark(benchmark_key),
	CONSTRAINT fact_benchmark_price_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key)
);


-- rankalpha.fact_corporate_action definition

-- Drop table

-- DROP TABLE rankalpha.fact_corporate_action;

CREATE TABLE rankalpha.fact_corporate_action (
	action_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock_key int4 NOT NULL,
	action_type varchar(12) NOT NULL,
	ex_date date NOT NULL,
	ratio_or_amt numeric(18, 8) NULL,
	declared_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_corporate_action_pkey PRIMARY KEY (action_id),
	CONSTRAINT fact_corporate_action_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
);


-- rankalpha.fact_factor_return definition

-- Drop table

-- DROP TABLE rankalpha.fact_factor_return;

CREATE TABLE rankalpha.fact_factor_return (
	date_key int4 NOT NULL,
	factor_key int4 NOT NULL,
	daily_return numeric(10, 6) NOT NULL,
	CONSTRAINT fact_factor_return_pkey PRIMARY KEY (date_key, factor_key),
	CONSTRAINT fact_factor_return_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_factor_return_factor_key_fkey FOREIGN KEY (factor_key) REFERENCES rankalpha.dim_factor(factor_key)
);


-- rankalpha.fact_fin_fundamentals definition

-- Drop table

-- DROP TABLE rankalpha.fact_fin_fundamentals;

CREATE TABLE rankalpha.fact_fin_fundamentals (
	date_key int4 NOT NULL,
	fact_id uuid DEFAULT uuid_generate_v4() NULL,
	stock_key int4 NOT NULL,
	source_key int4 NOT NULL,
	fiscal_year int2 NOT NULL,
	metric_key int4 NOT NULL,
	metric_value numeric(20, 4) NOT NULL,
	restated bool DEFAULT false NULL,
	ttm_flag bool DEFAULT false NULL,
	load_ts timestamptz DEFAULT now() NULL,
	fiscal_period varchar(3) NOT NULL,
	CONSTRAINT pk_fact_finfund PRIMARY KEY (date_key, stock_key, metric_key),
	CONSTRAINT fk_finfund_date FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fk_finfund_metric FOREIGN KEY (metric_key) REFERENCES rankalpha.dim_fin_metric(metric_key),
	CONSTRAINT fk_finfund_source FOREIGN KEY (source_key) REFERENCES rankalpha.dim_source(source_key),
	CONSTRAINT fk_finfund_stock FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
)
PARTITION BY RANGE (date_key);
CREATE INDEX ix_finfund_stock_metric ON ONLY rankalpha.fact_fin_fundamentals USING btree (stock_key, metric_key);


-- rankalpha.fact_fx_rate definition

-- Drop table

-- DROP TABLE rankalpha.fact_fx_rate;

CREATE TABLE rankalpha.fact_fx_rate (
	date_key int4 NOT NULL,
	from_ccy bpchar(3) NOT NULL,
	to_ccy bpchar(3) NOT NULL,
	mid_px numeric(18, 8) NOT NULL,
	CONSTRAINT fact_fx_rate_pkey PRIMARY KEY (date_key, from_ccy, to_ccy),
	CONSTRAINT fact_fx_rate_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key)
);


-- rankalpha.fact_iv_surface definition

-- Drop table

-- DROP TABLE rankalpha.fact_iv_surface;

CREATE TABLE rankalpha.fact_iv_surface (
	date_key int4 NOT NULL,
	stock_key int4 NOT NULL,
	tenor_key int4 NOT NULL,
	implied_vol numeric(8, 4) NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_iv_pkey PRIMARY KEY (date_key, stock_key, tenor_key),
	CONSTRAINT fact_iv_surface_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_iv_surface_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key),
	CONSTRAINT fact_iv_surface_tenor_key_fkey FOREIGN KEY (tenor_key) REFERENCES rankalpha.dim_tenor(tenor_key)
);


-- rankalpha.fact_news_articles definition

-- Drop table

-- DROP TABLE rankalpha.fact_news_articles;

CREATE TABLE rankalpha.fact_news_articles (
	article_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock_key int4 NOT NULL,
	source_key int4 NOT NULL,
	article_date int4 NOT NULL,
	headline text NOT NULL,
	"content" text NOT NULL,
	url text NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_news_articles_pkey PRIMARY KEY (article_date, article_id),
	CONSTRAINT fact_news_articles_article_date_fkey FOREIGN KEY (article_date) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_news_articles_source_key_fkey FOREIGN KEY (source_key) REFERENCES rankalpha.dim_source(source_key),
	CONSTRAINT fact_news_articles_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
)
PARTITION BY RANGE (article_date);


-- rankalpha.fact_portfolio_factor_exposure definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_factor_exposure;

CREATE TABLE rankalpha.fact_portfolio_factor_exposure (
	date_key int4 NOT NULL,
	portfolio_id uuid NOT NULL,
	factor_key int4 NOT NULL,
	exposure_value numeric(20, 6) NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_portfolio_factor_exposure_pkey PRIMARY KEY (date_key, portfolio_id, factor_key),
	CONSTRAINT fact_portfolio_factor_exposure_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_portfolio_factor_exposure_factor_key_fkey FOREIGN KEY (factor_key) REFERENCES rankalpha.dim_factor(factor_key),
	CONSTRAINT fact_portfolio_factor_exposure_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE
);


-- rankalpha.fact_portfolio_nav definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_nav;

CREATE TABLE rankalpha.fact_portfolio_nav (
	date_key int4 NOT NULL,
	portfolio_id uuid NOT NULL,
	nav_base_ccy numeric(20, 4) NOT NULL,
	gross_leverage numeric(6, 2) NULL,
	capital_inflow numeric(20, 4) NULL,
	capital_outflow numeric(20, 4) NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_portfolio_nav_pkey PRIMARY KEY (date_key, portfolio_id),
	CONSTRAINT fact_portfolio_nav_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_portfolio_nav_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE
);


-- rankalpha.fact_portfolio_pnl definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_pnl;

CREATE TABLE rankalpha.fact_portfolio_pnl (
	date_key int4 NOT NULL,
	portfolio_id uuid NOT NULL,
	unrealised_pnl numeric(20, 4) NULL,
	realised_pnl numeric(20, 4) NULL,
	dividend_income numeric(20, 4) NULL,
	fees numeric(20, 4) NULL,
	CONSTRAINT fact_portfolio_pnl_pkey PRIMARY KEY (date_key, portfolio_id),
	CONSTRAINT fact_portfolio_pnl_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_portfolio_pnl_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE
);


-- rankalpha.fact_portfolio_position_hist definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_position_hist;

CREATE TABLE rankalpha.fact_portfolio_position_hist (
	effective_date date NOT NULL,
	portfolio_id uuid NOT NULL,
	stock_key int4 NOT NULL,
	quantity numeric(20, 4) NOT NULL,
	avg_cost numeric(20, 4) NULL,
	run_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	CONSTRAINT fact_portfolio_position_hist_pkey PRIMARY KEY (effective_date, portfolio_id, stock_key),
	CONSTRAINT fact_portfolio_position_hist_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE,
	CONSTRAINT fact_portfolio_position_hist_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
);


-- rankalpha.fact_portfolio_risk definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_risk;

CREATE TABLE rankalpha.fact_portfolio_risk (
	date_key int4 NOT NULL,
	portfolio_id uuid NOT NULL,
	metric_name varchar(32) NOT NULL,
	metric_value numeric(20, 6) NOT NULL,
	methodology varchar(20) NULL,
	CONSTRAINT fact_portfolio_risk_pkey PRIMARY KEY (date_key, portfolio_id, metric_name),
	CONSTRAINT fact_portfolio_risk_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_portfolio_risk_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE
);


-- rankalpha.fact_portfolio_scenario_pnl definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_scenario_pnl;

CREATE TABLE rankalpha.fact_portfolio_scenario_pnl (
	date_key int4 NOT NULL,
	portfolio_id uuid NOT NULL,
	scenario_key int4 NOT NULL,
	pnl_value numeric(20, 4) NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_portfolio_scenario_pnl_pkey PRIMARY KEY (date_key, portfolio_id, scenario_key),
	CONSTRAINT fact_portfolio_scenario_pnl_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_portfolio_scenario_pnl_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE,
	CONSTRAINT fact_portfolio_scenario_pnl_scenario_key_fkey FOREIGN KEY (scenario_key) REFERENCES rankalpha.dim_stress_scenario(scenario_key)
);


-- rankalpha.fact_portfolio_trade definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_trade;

CREATE TABLE rankalpha.fact_portfolio_trade (
	trade_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	portfolio_id uuid NOT NULL,
	stock_key int4 NOT NULL,
	exec_ts timestamptz NOT NULL,
	side bpchar(4) NOT NULL,
	quantity numeric(20, 4) NOT NULL,
	price numeric(20, 4) NOT NULL,
	commission numeric(20, 4) NULL,
	venue varchar(12) NULL,
	strategy_tag varchar(40) NULL,
	CONSTRAINT fact_portfolio_trade_pkey PRIMARY KEY (trade_id),
	CONSTRAINT fact_portfolio_trade_side_check CHECK ((side = ANY (ARRAY['BUY'::bpchar, 'SELL'::bpchar]))),
	CONSTRAINT fact_portfolio_trade_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE,
	CONSTRAINT fact_portfolio_trade_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
);
CREATE INDEX idx_trade_portfolio_date ON rankalpha.fact_portfolio_trade USING btree (portfolio_id, exec_ts DESC);


-- rankalpha.fact_portfolio_var definition

-- Drop table

-- DROP TABLE rankalpha.fact_portfolio_var;

CREATE TABLE rankalpha.fact_portfolio_var (
	date_key int4 NOT NULL,
	portfolio_id uuid NOT NULL,
	var_method_key int4 NOT NULL,
	horizon_days int4 NOT NULL,
	confidence_pct numeric(5, 2) NOT NULL,
	var_value numeric(20, 4) NOT NULL,
	es_value numeric(20, 4) NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_portfolio_var_pkey PRIMARY KEY (date_key, portfolio_id, var_method_key, horizon_days, confidence_pct),
	CONSTRAINT fact_portfolio_var_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_portfolio_var_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE,
	CONSTRAINT fact_portfolio_var_var_method_key_fkey FOREIGN KEY (var_method_key) REFERENCES rankalpha.dim_var_method(var_method_key)
);


-- rankalpha.fact_risk_free_rate definition

-- Drop table

-- DROP TABLE rankalpha.fact_risk_free_rate;

CREATE TABLE rankalpha.fact_risk_free_rate (
	date_key int4 NOT NULL,
	tenor_key int4 NOT NULL,
	rate_pct numeric(10, 4) NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_rfr_pkey PRIMARY KEY (date_key, tenor_key),
	CONSTRAINT fact_risk_free_rate_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_risk_free_rate_tenor_key_fkey FOREIGN KEY (tenor_key) REFERENCES rankalpha.dim_tenor(tenor_key)
);


-- rankalpha.fact_score_history definition

-- Drop table

-- DROP TABLE rankalpha.fact_score_history;

CREATE TABLE rankalpha.fact_score_history (
	date_key int4 NOT NULL,
	fact_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock_key int4 NOT NULL,
	source_key int4 NOT NULL,
	score_type_key int4 NOT NULL,
	score numeric(5, 2) NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_score_history_pkey PRIMARY KEY (date_key, fact_id),
	CONSTRAINT fact_score_history_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_score_history_score_type_key_fkey FOREIGN KEY (score_type_key) REFERENCES rankalpha.dim_score_type(score_type_key),
	CONSTRAINT fact_score_history_source_key_fkey FOREIGN KEY (source_key) REFERENCES rankalpha.dim_source(source_key),
	CONSTRAINT fact_score_history_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
)
PARTITION BY RANGE (date_key);
CREATE INDEX idx_fact_score_history_score_type_key ON ONLY rankalpha.fact_score_history USING btree (score_type_key);
CREATE INDEX idx_fact_score_history_source_key ON ONLY rankalpha.fact_score_history USING btree (source_key);
CREATE INDEX idx_fact_score_history_stock_key ON ONLY rankalpha.fact_score_history USING btree (stock_key);


-- rankalpha.fact_screener_rank definition

-- Drop table

-- DROP TABLE rankalpha.fact_screener_rank;

CREATE TABLE rankalpha.fact_screener_rank (
	date_key int4 NOT NULL,
	fact_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock_key int4 NOT NULL,
	source_key int4 NOT NULL,
	style_key int4 NULL,
	rank_value int4 NOT NULL,
	screening_runid uuid NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_screener_rank_pkey PRIMARY KEY (date_key, fact_id),
	CONSTRAINT fact_screener_rank_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_screener_rank_source_key_fkey FOREIGN KEY (source_key) REFERENCES rankalpha.dim_source(source_key),
	CONSTRAINT fact_screener_rank_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key),
	CONSTRAINT fact_screener_rank_style_key_fkey FOREIGN KEY (style_key) REFERENCES rankalpha.dim_style(style_key)
)
PARTITION BY RANGE (date_key);
CREATE INDEX ix_fact_rank_date ON ONLY rankalpha.fact_screener_rank USING btree (date_key);
CREATE INDEX ix_fact_rank_sk_ssk_dk ON ONLY rankalpha.fact_screener_rank USING btree (stock_key, source_key, style_key, date_key);
CREATE INDEX ix_fact_rank_snapshot ON ONLY rankalpha.fact_screener_rank USING btree (screening_runid);
CREATE INDEX ix_fact_rank_source ON ONLY rankalpha.fact_screener_rank USING btree (source_key);
CREATE INDEX ix_fact_rank_stock ON ONLY rankalpha.fact_screener_rank USING btree (stock_key);
CREATE INDEX ix_fact_rank_style ON ONLY rankalpha.fact_screener_rank USING btree (style_key);


-- rankalpha.fact_security_price definition

-- Drop table

-- DROP TABLE rankalpha.fact_security_price;

CREATE TABLE rankalpha.fact_security_price (
	date_key int4 NOT NULL,
	stock_key int4 NOT NULL,
	open_px numeric(20, 4) NULL,
	high_px numeric(20, 4) NULL,
	low_px numeric(20, 4) NULL,
	close_px numeric(20, 4) NULL,
	total_return_factor numeric(18, 8) NULL,
	volume int8 NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_security_price_pkey PRIMARY KEY (date_key, stock_key),
	CONSTRAINT fact_security_price_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_security_price_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
);


-- rankalpha.fact_stock_borrow_rate definition

-- Drop table

-- DROP TABLE rankalpha.fact_stock_borrow_rate;

CREATE TABLE rankalpha.fact_stock_borrow_rate (
	date_key int4 NOT NULL,
	stock_key int4 NOT NULL,
	borrow_rate_bp numeric(12, 4) NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_borrow_pkey PRIMARY KEY (date_key, stock_key),
	CONSTRAINT fact_stock_borrow_rate_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_stock_borrow_rate_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
);


-- rankalpha.fact_stock_correlation definition

-- Drop table

-- DROP TABLE rankalpha.fact_stock_correlation;

CREATE TABLE rankalpha.fact_stock_correlation (
	date_key int4 NOT NULL,
	fact_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock1_key int4 NOT NULL,
	stock2_key int4 NOT NULL,
	corr_method_key int4 NOT NULL,
	corr_window_key int4 NOT NULL,
	correlation_value numeric(6, 4) NOT NULL,
	corr_runid uuid NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT chk_stock_order CHECK ((stock1_key < stock2_key)),
	CONSTRAINT fact_stock_correlation_correlation_value_check CHECK (((correlation_value >= ('-1'::integer)::numeric) AND (correlation_value <= (1)::numeric))),
	CONSTRAINT pk_fact_stock_corr PRIMARY KEY (date_key, fact_id),
	CONSTRAINT fact_stock_correlation_corr_method_key_fkey FOREIGN KEY (corr_method_key) REFERENCES rankalpha.dim_corr_method(corr_method_key),
	CONSTRAINT fact_stock_correlation_corr_window_key_fkey FOREIGN KEY (corr_window_key) REFERENCES rankalpha.dim_corr_window(corr_window_key),
	CONSTRAINT fact_stock_correlation_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_stock_correlation_stock1_key_fkey FOREIGN KEY (stock1_key) REFERENCES rankalpha.dim_stock(stock_key),
	CONSTRAINT fact_stock_correlation_stock2_key_fkey FOREIGN KEY (stock2_key) REFERENCES rankalpha.dim_stock(stock_key)
)
PARTITION BY RANGE (date_key);
CREATE INDEX idx_corr_date ON ONLY rankalpha.fact_stock_correlation USING btree (date_key);
CREATE INDEX idx_corr_pair_date ON ONLY rankalpha.fact_stock_correlation USING btree (stock1_key, stock2_key, date_key);


-- rankalpha.fact_stock_score_types definition

-- Drop table

-- DROP TABLE rankalpha.fact_stock_score_types;

CREATE TABLE rankalpha.fact_stock_score_types (
	date_key int4 NOT NULL,
	fact_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock_key int4 NOT NULL,
	score_type_key int4 NOT NULL,
	score_value numeric(5, 2) NOT NULL,
	rank_value int4 NOT NULL,
	score_runid uuid NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_stock_score_types_pkey PRIMARY KEY (date_key, fact_id),
	CONSTRAINT fact_stock_score_types_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_stock_score_types_score_type_key_fkey FOREIGN KEY (score_type_key) REFERENCES rankalpha.dim_score_type(score_type_key),
	CONSTRAINT fact_stock_score_types_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
)
PARTITION BY RANGE (date_key);
CREATE INDEX idx_fact_stock_score_types_score_type_stock ON ONLY rankalpha.fact_stock_score_types USING btree (score_type_key, stock_key);


-- rankalpha.fact_stock_scores definition

-- Drop table

-- DROP TABLE rankalpha.fact_stock_scores;

CREATE TABLE rankalpha.fact_stock_scores (
	date_key int4 NOT NULL,
	fact_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	stock_key int4 NOT NULL,
	style_key int4 NOT NULL,
	score_value numeric(5, 2) NOT NULL,
	rank_value int4 NOT NULL,
	score_runid uuid NOT NULL,
	load_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_stock_scores_pkey PRIMARY KEY (date_key, fact_id),
	CONSTRAINT fact_stock_scores_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_stock_scores_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key),
	CONSTRAINT fact_stock_scores_style_key_fkey FOREIGN KEY (style_key) REFERENCES rankalpha.dim_style(style_key)
)
PARTITION BY RANGE (date_key);
CREATE INDEX idx_fact_stock_scores_stock_style ON ONLY rankalpha.fact_stock_scores USING btree (stock_key, style_key);


-- rankalpha.fact_trade_recommendation definition

-- Drop table

-- DROP TABLE rankalpha.fact_trade_recommendation;

CREATE TABLE rankalpha.fact_trade_recommendation (
	recommendation_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	date_key int4 NOT NULL,
	stock_key int4 NOT NULL,
	source_key int4 NOT NULL,
	"action" rankalpha."trade_action" NOT NULL,
	recommended_price numeric(20, 4) NULL,
	stop_loss_price numeric(20, 4) NULL,
	take_profit_price numeric(20, 4) NULL,
	size_shares int4 NULL,
	size_percent numeric(6, 2) NULL,
	confidence_key int4 NULL,
	timeframe_key int4 NULL,
	strategy_name varchar(50) NULL,
	description varchar(1000) NULL,
	is_live bool DEFAULT false NULL,
	filled_price numeric(20, 4) NULL,
	filled_date date NULL,
	create_ts timestamptz DEFAULT now() NOT NULL,
	update_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT fact_trade_recommendation_pkey PRIMARY KEY (recommendation_id),
	CONSTRAINT uq_trade_rec UNIQUE (date_key, stock_key, source_key, action),
	CONSTRAINT fact_trade_recommendation_confidence_key_fkey FOREIGN KEY (confidence_key) REFERENCES rankalpha.dim_confidence(confidence_key),
	CONSTRAINT fact_trade_recommendation_date_key_fkey FOREIGN KEY (date_key) REFERENCES rankalpha.dim_date(date_key),
	CONSTRAINT fact_trade_recommendation_source_key_fkey FOREIGN KEY (source_key) REFERENCES rankalpha.dim_source(source_key),
	CONSTRAINT fact_trade_recommendation_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key),
	CONSTRAINT fact_trade_recommendation_timeframe_key_fkey FOREIGN KEY (timeframe_key) REFERENCES rankalpha.dim_timeframe(timeframe_key)
);

-- Table Triggers

create trigger trg_fact_trade_rec_ts before
update
    on
    rankalpha.fact_trade_recommendation for each row execute function trg_set_fact_trade_rec_update_ts();


-- rankalpha.portfolio_position definition

-- Drop table

-- DROP TABLE rankalpha.portfolio_position;

CREATE TABLE rankalpha.portfolio_position (
	position_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	portfolio_id uuid NOT NULL,
	stock_key int4 NOT NULL,
	quantity numeric(20, 4) NOT NULL,
	avg_cost numeric(20, 4) NULL,
	open_date date NULL,
	last_update_ts timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT portfolio_position_pkey PRIMARY KEY (position_id),
	CONSTRAINT uq_portfolio_stock UNIQUE (portfolio_id, stock_key),
	CONSTRAINT portfolio_position_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES rankalpha.portfolio(portfolio_id) ON DELETE CASCADE,
	CONSTRAINT portfolio_position_stock_key_fkey FOREIGN KEY (stock_key) REFERENCES rankalpha.dim_stock(stock_key)
);
CREATE INDEX idx_portpos_portfolio ON rankalpha.portfolio_position USING btree (portfolio_id);
CREATE INDEX idx_portpos_stock ON rankalpha.portfolio_position USING btree (stock_key);


-- views
-- rankalpha.v_latest_screener source

CREATE OR REPLACE VIEW rankalpha.v_latest_screener
AS SELECT f.date_key,
    f.fact_id,
    f.stock_key,
    f.source_key,
    f.style_key,
    f.rank_value,
    f.screening_runid,
    f.load_ts
   FROM fact_screener_rank f
     JOIN ( SELECT max(fact_screener_rank.date_key) AS max_date
           FROM fact_screener_rank) m ON f.date_key = m.max_date;


-- rankalpha.v_latest_screener_values source

CREATE OR REPLACE VIEW rankalpha.v_latest_screener_values
AS WITH latest AS (
         SELECT max(fact_screener_rank.date_key) AS max_date
           FROM fact_screener_rank
        )
 SELECT f.date_key,
    dd.full_date,
    ds.symbol,
    ds.company_name,
    ds.sector,
    ds.exchange,
    src.source_name AS source,
    sty.style_name AS style,
    min(f.rank_value) AS rank_value,
    (array_agg(f.screening_runid ORDER BY f.load_ts DESC))[1] AS screening_runid,
    max(f.load_ts) AS load_ts,
    count(*) AS appearances
   FROM fact_screener_rank f
     JOIN latest ON f.date_key = latest.max_date
     JOIN dim_date dd ON f.date_key = dd.date_key
     JOIN dim_stock ds ON f.stock_key = ds.stock_key
     JOIN dim_source src ON f.source_key = src.source_key
     JOIN dim_style sty ON f.style_key = sty.style_key
  GROUP BY f.date_key, dd.full_date, ds.symbol, ds.company_name, ds.sector, ds.exchange, src.source_name, sty.style_name;


-- rankalpha.vw_fin_fundamentals source

CREATE OR REPLACE VIEW rankalpha.vw_fin_fundamentals
AS SELECT f.date_key,
    dt.full_date AS as_of_date,
    s.symbol,
    s.company_name,
    m.metric_code,
    m.metric_name,
    f.fiscal_year,
    f.fiscal_period,
    f.metric_value,
    src.source_name,
    f.load_ts
   FROM fact_fin_fundamentals f
     JOIN dim_stock s ON s.stock_key = f.stock_key
     JOIN dim_fin_metric m ON m.metric_key = f.metric_key
     JOIN dim_date dt ON dt.date_key = f.date_key
     JOIN dim_source src ON src.source_key = f.source_key;


-- rankalpha.vw_iv_surface source

CREATE OR REPLACE VIEW rankalpha.vw_iv_surface
AS SELECT d.full_date AS iv_date,
    s.symbol,
    t.tenor_label,
    f.implied_vol
   FROM fact_iv_surface f
     JOIN dim_date d ON d.date_key = f.date_key
     JOIN dim_stock s ON s.stock_key = f.stock_key
     JOIN dim_tenor t ON t.tenor_key = f.tenor_key;


-- rankalpha.vw_news_sentiment source

CREATE OR REPLACE VIEW rankalpha.vw_news_sentiment
AS SELECT a.article_id,
    a.article_date AS date_key,
    d.full_date AS article_date,
    s.stock_key,
    s.symbol,
    a.source_key,
    src.source_name,
    src.version AS source_version,
    n.sentiment_score,
    n.sentiment_label,
    a.headline,
    a.url,
    a.load_ts
   FROM fact_news_sentiment n
     JOIN fact_news_articles a ON a.article_id = n.article_id
     JOIN dim_stock s ON s.stock_key = a.stock_key
     JOIN dim_date d ON d.date_key = a.article_date
     JOIN dim_source src ON src.source_key = a.source_key;


-- rankalpha.vw_portfolio_factor_exposure source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_factor_exposure
AS SELECT d.full_date AS exposure_date,
    p.portfolio_name,
    f.model_name,
    f.factor_name,
    e.exposure_value,
    e.load_ts
   FROM fact_portfolio_factor_exposure e
     JOIN dim_date d ON d.date_key = e.date_key
     JOIN portfolio p ON p.portfolio_id = e.portfolio_id
     JOIN dim_factor f ON f.factor_key = e.factor_key;


-- rankalpha.vw_portfolio_performance source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_performance
AS SELECT nav.date_key,
    d.full_date,
    p.portfolio_id,
    p.portfolio_name,
    nav.nav_base_ccy,
    lag(nav.nav_base_ccy) OVER (PARTITION BY p.portfolio_id ORDER BY nav.date_key) AS nav_prev,
    nav.nav_base_ccy / lag(nav.nav_base_ccy) OVER (PARTITION BY p.portfolio_id ORDER BY nav.date_key) - 1::numeric AS daily_return
   FROM fact_portfolio_nav nav
     JOIN portfolio p USING (portfolio_id)
     JOIN dim_date d USING (date_key);


-- rankalpha.vw_portfolio_position source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_position
AS SELECT p.portfolio_id,
    p.portfolio_name,
    pp.position_id,
    ds.symbol,
    ds.company_name,
    pp.quantity,
    pp.avg_cost,
    pp.quantity * pp.avg_cost AS position_cost,
    pp.open_date,
    pp.last_update_ts
   FROM portfolio p
     JOIN portfolio_position pp USING (portfolio_id)
     JOIN dim_stock ds ON ds.stock_key = pp.stock_key;


-- rankalpha.vw_portfolio_scenario_pnl source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_scenario_pnl
AS SELECT d.full_date AS scenario_date,
    p.portfolio_name,
    s.scenario_name,
    s.category,
    s.severity_label,
    pnl.pnl_value,
    pnl.load_ts
   FROM fact_portfolio_scenario_pnl pnl
     JOIN dim_date d ON d.date_key = pnl.date_key
     JOIN portfolio p ON p.portfolio_id = pnl.portfolio_id
     JOIN dim_stress_scenario s ON s.scenario_key = pnl.scenario_key;


-- rankalpha.vw_portfolio_snapshot source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_snapshot
AS SELECT p.portfolio_id,
    p.portfolio_name,
    ds.symbol,
    ds.company_name,
    pp.quantity,
    pp.avg_cost,
    sp.close_px AS last_close,
    pp.quantity * sp.close_px AS market_value,
    nav.nav_base_ccy AS nav,
    pp.quantity * sp.close_px / nav.nav_base_ccy AS weight_pct,
    pp.last_update_ts
   FROM portfolio_position pp
     JOIN portfolio p USING (portfolio_id)
     JOIN dim_stock ds ON ds.stock_key = pp.stock_key
     JOIN LATERAL ( SELECT sp_1.close_px
           FROM fact_security_price sp_1
          WHERE sp_1.stock_key = pp.stock_key
          ORDER BY sp_1.date_key DESC
         LIMIT 1) sp ON true
     JOIN LATERAL ( SELECT nav_1.nav_base_ccy
           FROM fact_portfolio_nav nav_1
          WHERE nav_1.portfolio_id = p.portfolio_id
          ORDER BY nav_1.date_key DESC
         LIMIT 1) nav ON true;


-- rankalpha.vw_portfolio_top_contrib source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_top_contrib
AS WITH last_prices AS (
         SELECT fact_security_price.stock_key,
            fact_security_price.close_px,
            row_number() OVER (PARTITION BY fact_security_price.stock_key ORDER BY fact_security_price.date_key DESC) AS rn
           FROM fact_security_price
        )
 SELECT p.portfolio_id,
    p.portfolio_name,
    ds.symbol,
    ds.company_name,
    pp.quantity,
    lp.close_px,
    pp.quantity * lp.close_px - pp.quantity * pp.avg_cost AS unreal_pnl
   FROM portfolio_position pp
     JOIN portfolio p USING (portfolio_id)
     JOIN dim_stock ds ON ds.stock_key = pp.stock_key
     JOIN last_prices lp ON lp.stock_key = pp.stock_key AND lp.rn = 1
  ORDER BY (abs(pp.quantity * lp.close_px - pp.quantity * pp.avg_cost)) DESC
 LIMIT 20;


-- rankalpha.vw_portfolio_turnover source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_turnover
AS SELECT dd.full_date,
    t.portfolio_id,
    p.portfolio_name,
    sum(abs(t.quantity * t.price)) AS notional_traded,
    nav.nav_base_ccy,
    sum(abs(t.quantity * t.price)) / nav.nav_base_ccy AS turnover_pct
   FROM fact_portfolio_trade t
     JOIN dim_date dd ON dd.full_date = date(t.exec_ts)
     JOIN LATERAL ( SELECT nav_1.nav_base_ccy
           FROM fact_portfolio_nav nav_1
          WHERE nav_1.portfolio_id = t.portfolio_id AND nav_1.date_key = dd.date_key) nav ON true
     JOIN portfolio p ON p.portfolio_id = t.portfolio_id
  GROUP BY dd.full_date, t.portfolio_id, p.portfolio_name, nav.nav_base_ccy;


-- rankalpha.vw_portfolio_var source

CREATE OR REPLACE VIEW rankalpha.vw_portfolio_var
AS SELECT d.full_date AS risk_date,
    p.portfolio_name,
    m.method_label,
    f.horizon_days,
    f.confidence_pct,
    f.var_value,
    f.es_value,
    f.load_ts
   FROM fact_portfolio_var f
     JOIN dim_date d ON d.date_key = f.date_key
     JOIN portfolio p ON p.portfolio_id = f.portfolio_id
     JOIN dim_var_method m ON m.var_method_key = f.var_method_key;


-- rankalpha.vw_risk_dashboard source

CREATE OR REPLACE VIEW rankalpha.vw_risk_dashboard
AS SELECT r.date_key,
    d.full_date,
    p.portfolio_name,
    max(
        CASE
            WHEN r.metric_name::text = 'VaR_95_1d'::text THEN r.metric_value
            ELSE NULL::numeric
        END) AS var_95_1d,
    max(
        CASE
            WHEN r.metric_name::text = 'Beta_SP500'::text THEN r.metric_value
            ELSE NULL::numeric
        END) AS beta_spx,
    max(
        CASE
            WHEN r.metric_name::text = 'Liquidity_Days'::text THEN r.metric_value
            ELSE NULL::numeric
        END) AS liq_days
   FROM fact_portfolio_risk r
     JOIN portfolio p USING (portfolio_id)
     JOIN dim_date d USING (date_key)
  GROUP BY r.date_key, d.full_date, p.portfolio_name;


-- rankalpha.vw_risk_free_rate source

CREATE OR REPLACE VIEW rankalpha.vw_risk_free_rate
AS SELECT d.full_date AS rate_date,
    t.tenor_label,
    f.rate_pct
   FROM fact_risk_free_rate f
     JOIN dim_date d ON d.date_key = f.date_key
     JOIN dim_tenor t ON t.tenor_key = f.tenor_key;


-- rankalpha.vw_score_history source

CREATE OR REPLACE VIEW rankalpha.vw_score_history
AS SELECT h.date_key,
    d.full_date AS as_of_date,
    s.symbol,
    st.score_type_name,
    h.score,
    src.source_name,
    h.load_ts
   FROM fact_score_history h
     JOIN dim_stock s ON s.stock_key = h.stock_key
     JOIN dim_score_type st ON st.score_type_key = h.score_type_key
     JOIN dim_date d ON d.date_key = h.date_key
     JOIN dim_source src ON src.source_key = h.source_key;


-- rankalpha.vw_screener_rank source

CREATE OR REPLACE VIEW rankalpha.vw_screener_rank
AS SELECT r.date_key,
    d.full_date AS as_of_date,
    s.symbol,
    sty.style_name,
    r.rank_value,
    r.screening_runid,
    r.load_ts,
    src.source_name
   FROM fact_screener_rank r
     JOIN dim_stock s ON s.stock_key = r.stock_key
     LEFT JOIN dim_style sty ON sty.style_key = r.style_key
     JOIN dim_date d ON d.date_key = r.date_key
     JOIN dim_source src ON src.source_key = r.source_key;


-- rankalpha.vw_stock_borrow_rate source

CREATE OR REPLACE VIEW rankalpha.vw_stock_borrow_rate
AS SELECT d.full_date AS borrow_date,
    s.symbol,
    f.borrow_rate_bp
   FROM fact_stock_borrow_rate f
     JOIN dim_date d ON d.date_key = f.date_key
     JOIN dim_stock s ON s.stock_key = f.stock_key;


-- rankalpha.vw_stock_style_scores source

CREATE OR REPLACE VIEW rankalpha.vw_stock_style_scores
AS SELECT ss.date_key,
    d.full_date AS as_of_date,
    s.symbol,
    sty.style_name,
    ss.score_value,
    ss.rank_value,
    ss.score_runid,
    ss.load_ts
   FROM fact_stock_scores ss
     JOIN dim_stock s ON s.stock_key = ss.stock_key
     JOIN dim_style sty ON sty.style_key = ss.style_key
     JOIN dim_date d ON d.date_key = ss.date_key;


-- rankalpha.vw_trade_recommendation source

CREATE OR REPLACE VIEW rankalpha.vw_trade_recommendation
AS SELECT tr.recommendation_id,
    d.full_date AS recommendation_date,
    s.symbol,
    s.exchange,
    at.asset_type_name AS asset_type,
    src.source_name,
    src.version AS source_version,
    tr.action,
    tr.recommended_price,
    tr.stop_loss_price,
    tr.take_profit_price,
    tr.size_shares,
    tr.size_percent,
    conf.confidence_label,
    tf.timeframe_label,
    tr.strategy_name,
    tr.description,
    tr.is_live,
    tr.filled_price,
    tr.filled_date,
    tr.create_ts,
    tr.update_ts
   FROM fact_trade_recommendation tr
     JOIN dim_date d ON d.date_key = tr.date_key
     JOIN dim_stock s ON s.stock_key = tr.stock_key
     LEFT JOIN dim_asset_type at ON at.asset_type_key = s.asset_type_key
     JOIN dim_source src ON src.source_key = tr.source_key
     LEFT JOIN dim_confidence conf ON conf.confidence_key = tr.confidence_key
     LEFT JOIN dim_timeframe tf ON tf.timeframe_key = tr.timeframe_key;


-- indexes
CREATE UNIQUE INDEX dim_asset_type_asset_type_name_key ON rankalpha.dim_asset_type USING btree (asset_type_name);

CREATE UNIQUE INDEX dim_asset_type_pkey ON rankalpha.dim_asset_type USING btree (asset_type_key);

CREATE UNIQUE INDEX dim_benchmark_benchmark_name_key ON rankalpha.dim_benchmark USING btree (benchmark_name);

CREATE UNIQUE INDEX dim_benchmark_pkey ON rankalpha.dim_benchmark USING btree (benchmark_key);

CREATE UNIQUE INDEX dim_confidence_confidence_label_key ON rankalpha.dim_confidence USING btree (confidence_label);

CREATE UNIQUE INDEX dim_confidence_pkey ON rankalpha.dim_confidence USING btree (confidence_key);

CREATE UNIQUE INDEX dim_corr_method_corr_method_name_key ON rankalpha.dim_corr_method USING btree (corr_method_name);

CREATE UNIQUE INDEX dim_corr_method_pkey ON rankalpha.dim_corr_method USING btree (corr_method_key);

CREATE UNIQUE INDEX dim_corr_window_pkey ON rankalpha.dim_corr_window USING btree (corr_window_key);

CREATE UNIQUE INDEX dim_corr_window_window_label_key ON rankalpha.dim_corr_window USING btree (window_label);

CREATE UNIQUE INDEX dim_date_full_date_key ON rankalpha.dim_date USING btree (full_date);

CREATE UNIQUE INDEX dim_date_pkey ON rankalpha.dim_date USING btree (date_key);

CREATE UNIQUE INDEX dim_factor_model_name_factor_name_key ON rankalpha.dim_factor USING btree (model_name, factor_name);

CREATE UNIQUE INDEX dim_factor_pkey ON rankalpha.dim_factor USING btree (factor_key);

CREATE UNIQUE INDEX dim_fin_metric_metric_code_key ON rankalpha.dim_fin_metric USING btree (metric_code);

CREATE UNIQUE INDEX dim_fin_metric_pkey ON rankalpha.dim_fin_metric USING btree (metric_key);

CREATE UNIQUE INDEX dim_rating_pkey ON rankalpha.dim_rating USING btree (rating_key);

CREATE UNIQUE INDEX dim_rating_rating_label_key ON rankalpha.dim_rating USING btree (rating_label);

CREATE UNIQUE INDEX dim_score_type_pkey ON rankalpha.dim_score_type USING btree (score_type_key);

CREATE UNIQUE INDEX dim_score_type_score_type_name_key ON rankalpha.dim_score_type USING btree (score_type_name);

CREATE UNIQUE INDEX dim_source_pkey ON rankalpha.dim_source USING btree (source_key);

CREATE UNIQUE INDEX dim_source_source_name_key ON rankalpha.dim_source USING btree (source_name);

CREATE UNIQUE INDEX dim_source_source_name_version_uc ON rankalpha.dim_source USING btree (source_name, version);

CREATE UNIQUE INDEX dim_source_source_name_version_uidx ON rankalpha.dim_source USING btree (source_name, version);

CREATE UNIQUE INDEX dim_stock_pkey ON rankalpha.dim_stock USING btree (stock_key);

CREATE UNIQUE INDEX dim_stock_symbol_key ON rankalpha.dim_stock USING btree (symbol);

CREATE UNIQUE INDEX dim_stress_scenario_pkey ON rankalpha.dim_stress_scenario USING btree (scenario_key);

CREATE UNIQUE INDEX dim_stress_scenario_scenario_name_key ON rankalpha.dim_stress_scenario USING btree (scenario_name);

CREATE UNIQUE INDEX dim_style_pkey ON rankalpha.dim_style USING btree (style_key);

CREATE UNIQUE INDEX dim_style_style_name_key ON rankalpha.dim_style USING btree (style_name);

CREATE UNIQUE INDEX dim_tenor_pkey ON rankalpha.dim_tenor USING btree (tenor_key);

CREATE UNIQUE INDEX dim_tenor_tenor_label_key ON rankalpha.dim_tenor USING btree (tenor_label);

CREATE UNIQUE INDEX dim_timeframe_pkey ON rankalpha.dim_timeframe USING btree (timeframe_key);

CREATE UNIQUE INDEX dim_timeframe_timeframe_label_key ON rankalpha.dim_timeframe USING btree (timeframe_label);

CREATE UNIQUE INDEX dim_trend_category_pkey ON rankalpha.dim_trend_category USING btree (trend_key);

CREATE UNIQUE INDEX dim_trend_category_trend_label_key ON rankalpha.dim_trend_category USING btree (trend_label);

CREATE UNIQUE INDEX dim_var_method_method_label_key ON rankalpha.dim_var_method USING btree (method_label);

CREATE UNIQUE INDEX dim_var_method_pkey ON rankalpha.dim_var_method USING btree (var_method_key);

CREATE UNIQUE INDEX fact_ai_catalyst_pkey ON rankalpha.fact_ai_catalyst USING btree (catalyst_id);

CREATE INDEX idx_ai_catalyst_type_date ON rankalpha.fact_ai_catalyst USING btree (analysis_id, catalyst_type, expected_date);

CREATE UNIQUE INDEX fact_ai_data_gap_pkey ON rankalpha.fact_ai_data_gap USING btree (analysis_id, gap_text);

CREATE INDEX idx_ai_data_gap_analysis ON rankalpha.fact_ai_data_gap USING btree (analysis_id);

CREATE UNIQUE INDEX fact_ai_factor_score_pkey ON rankalpha.fact_ai_factor_score USING btree (analysis_id, style_key);

CREATE INDEX idx_ai_factor_score ON rankalpha.fact_ai_factor_score USING btree (analysis_id, style_key);

CREATE UNIQUE INDEX fact_ai_headline_risk_pkey ON rankalpha.fact_ai_headline_risk USING btree (analysis_id, risk_text);

CREATE INDEX idx_ai_headline_risk_analysis ON rankalpha.fact_ai_headline_risk USING btree (analysis_id);

CREATE UNIQUE INDEX fact_ai_macro_risk_pkey ON rankalpha.fact_ai_macro_risk USING btree (analysis_id, risk_text);

CREATE INDEX idx_ai_macro_risk_analysis ON rankalpha.fact_ai_macro_risk USING btree (analysis_id);

CREATE UNIQUE INDEX fact_ai_peer_comparison_pkey ON rankalpha.fact_ai_peer_comparison USING btree (analysis_id, peer_stock_key);

CREATE INDEX idx_ai_peer_analysis_pair ON rankalpha.fact_ai_peer_comparison USING btree (analysis_id, peer_stock_key);

CREATE UNIQUE INDEX fact_ai_price_scenario_pkey ON rankalpha.fact_ai_price_scenario USING btree (analysis_id, scenario_type);

CREATE INDEX idx_ai_price_scenario_type ON rankalpha.fact_ai_price_scenario USING btree (analysis_id, scenario_type);

CREATE UNIQUE INDEX fact_ai_stock_analysis_pkey ON ONLY rankalpha.fact_ai_stock_analysis USING btree (date_key, analysis_id);

CREATE INDEX idx_ai_stock_analysis_rating_conf ON ONLY rankalpha.fact_ai_stock_analysis USING btree (overall_rating_key, confidence_key);

CREATE INDEX idx_ai_stock_analysis_stock_date ON ONLY rankalpha.fact_ai_stock_analysis USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2010_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2010 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2010_pkey ON rankalpha.fact_ai_stock_analysis_2010 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2010_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2010 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2011_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2011 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2011_pkey ON rankalpha.fact_ai_stock_analysis_2011 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2011_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2011 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2012_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2012 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2012_pkey ON rankalpha.fact_ai_stock_analysis_2012 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2012_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2012 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2013_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2013 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2013_pkey ON rankalpha.fact_ai_stock_analysis_2013 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2013_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2013 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2014_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2014 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2014_pkey ON rankalpha.fact_ai_stock_analysis_2014 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2014_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2014 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2015_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2015 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2015_pkey ON rankalpha.fact_ai_stock_analysis_2015 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2015_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2015 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2016_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2016 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2016_pkey ON rankalpha.fact_ai_stock_analysis_2016 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2016_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2016 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2017_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2017 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2017_pkey ON rankalpha.fact_ai_stock_analysis_2017 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2017_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2017 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2018_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2018 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2018_pkey ON rankalpha.fact_ai_stock_analysis_2018 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2018_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2018 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2019_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2019 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2019_pkey ON rankalpha.fact_ai_stock_analysis_2019 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2019_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2019 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2020_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2020 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2020_pkey ON rankalpha.fact_ai_stock_analysis_2020 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2020_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2020 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2021_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2021 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2021_pkey ON rankalpha.fact_ai_stock_analysis_2021 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2021_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2021 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2022_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2022 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2022_pkey ON rankalpha.fact_ai_stock_analysis_2022 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2022_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2022 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2023_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2023 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2023_pkey ON rankalpha.fact_ai_stock_analysis_2023 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2023_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2023 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2024_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2024 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2024_pkey ON rankalpha.fact_ai_stock_analysis_2024 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2024_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2024 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2025_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2025 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2025_pkey ON rankalpha.fact_ai_stock_analysis_2025 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2025_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2025 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2026_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2026 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2026_pkey ON rankalpha.fact_ai_stock_analysis_2026 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2026_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2026 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2027_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2027 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2027_pkey ON rankalpha.fact_ai_stock_analysis_2027 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2027_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2027 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2028_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2028 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2028_pkey ON rankalpha.fact_ai_stock_analysis_2028 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2028_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2028 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2029_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2029 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2029_pkey ON rankalpha.fact_ai_stock_analysis_2029 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2029_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2029 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2030_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2030 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2030_pkey ON rankalpha.fact_ai_stock_analysis_2030 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2030_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2030 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2031_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2031 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2031_pkey ON rankalpha.fact_ai_stock_analysis_2031 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2031_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2031 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2032_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2032 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2032_pkey ON rankalpha.fact_ai_stock_analysis_2032 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2032_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2032 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2033_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2033 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2033_pkey ON rankalpha.fact_ai_stock_analysis_2033 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2033_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2033 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2034_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2034 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2034_pkey ON rankalpha.fact_ai_stock_analysis_2034 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2034_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2034 USING btree (stock_key, date_key);

CREATE INDEX fact_ai_stock_analysis_2035_overall_rating_key_confidence_k_idx ON rankalpha.fact_ai_stock_analysis_2035 USING btree (overall_rating_key, confidence_key);

CREATE UNIQUE INDEX fact_ai_stock_analysis_2035_pkey ON rankalpha.fact_ai_stock_analysis_2035 USING btree (date_key, analysis_id);

CREATE INDEX fact_ai_stock_analysis_2035_stock_key_date_key_idx ON rankalpha.fact_ai_stock_analysis_2035 USING btree (stock_key, date_key);

CREATE UNIQUE INDEX fact_ai_valuation_metrics_pkey ON rankalpha.fact_ai_valuation_metrics USING btree (analysis_id);

CREATE INDEX idx_ai_val_metrics_analysis ON rankalpha.fact_ai_valuation_metrics USING btree (analysis_id);

CREATE UNIQUE INDEX fact_benchmark_price_pkey ON rankalpha.fact_benchmark_price USING btree (date_key, benchmark_key);

CREATE UNIQUE INDEX fact_corporate_action_pkey ON rankalpha.fact_corporate_action USING btree (action_id);

CREATE UNIQUE INDEX fact_factor_return_pkey ON rankalpha.fact_factor_return USING btree (date_key, factor_key);

CREATE INDEX ix_finfund_stock_metric ON ONLY rankalpha.fact_fin_fundamentals USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX pk_fact_finfund ON ONLY rankalpha.fact_fin_fundamentals USING btree (date_key, stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2020_pkey ON rankalpha.fact_fin_fundamentals_2020 USING btree (date_key, stock_key, metric_key);

CREATE INDEX finfund_2020_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2020 USING btree (metric_key, date_key);

CREATE INDEX finfund_2020_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2020 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2021_pkey ON rankalpha.fact_fin_fundamentals_2021 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2021_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2021 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2021_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2021 USING btree (metric_key, date_key);

CREATE INDEX finfund_2021_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2021 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2022_pkey ON rankalpha.fact_fin_fundamentals_2022 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2022_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2022 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2022_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2022 USING btree (metric_key, date_key);

CREATE INDEX finfund_2022_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2022 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2023_pkey ON rankalpha.fact_fin_fundamentals_2023 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2023_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2023 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2023_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2023 USING btree (metric_key, date_key);

CREATE INDEX finfund_2023_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2023 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2024_pkey ON rankalpha.fact_fin_fundamentals_2024 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2024_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2024 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2024_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2024 USING btree (metric_key, date_key);

CREATE INDEX finfund_2024_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2024 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2025_pkey ON rankalpha.fact_fin_fundamentals_2025 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2025_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2025 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2025_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2025 USING btree (metric_key, date_key);

CREATE INDEX finfund_2025_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2025 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2026_pkey ON rankalpha.fact_fin_fundamentals_2026 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2026_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2026 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2026_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2026 USING btree (metric_key, date_key);

CREATE INDEX finfund_2026_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2026 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2027_pkey ON rankalpha.fact_fin_fundamentals_2027 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2027_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2027 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2027_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2027 USING btree (metric_key, date_key);

CREATE INDEX finfund_2027_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2027 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2028_pkey ON rankalpha.fact_fin_fundamentals_2028 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2028_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2028 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2028_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2028 USING btree (metric_key, date_key);

CREATE INDEX finfund_2028_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2028 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2029_pkey ON rankalpha.fact_fin_fundamentals_2029 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2029_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2029 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2029_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2029 USING btree (metric_key, date_key);

CREATE INDEX finfund_2029_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2029 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2030_pkey ON rankalpha.fact_fin_fundamentals_2030 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2030_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2030 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2030_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2030 USING btree (metric_key, date_key);

CREATE INDEX finfund_2030_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2030 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2031_pkey ON rankalpha.fact_fin_fundamentals_2031 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2031_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2031 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2031_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2031 USING btree (metric_key, date_key);

CREATE INDEX finfund_2031_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2031 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2032_pkey ON rankalpha.fact_fin_fundamentals_2032 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2032_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2032 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2032_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2032 USING btree (metric_key, date_key);

CREATE INDEX finfund_2032_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2032 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2033_pkey ON rankalpha.fact_fin_fundamentals_2033 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2033_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2033 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2033_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2033 USING btree (metric_key, date_key);

CREATE INDEX finfund_2033_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2033 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2034_pkey ON rankalpha.fact_fin_fundamentals_2034 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2034_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2034 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2034_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2034 USING btree (metric_key, date_key);

CREATE INDEX finfund_2034_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2034 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2035_pkey ON rankalpha.fact_fin_fundamentals_2035 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2035_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2035 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2035_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2035 USING btree (metric_key, date_key);

CREATE INDEX finfund_2035_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2035 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2036_pkey ON rankalpha.fact_fin_fundamentals_2036 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2036_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2036 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2036_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2036 USING btree (metric_key, date_key);

CREATE INDEX finfund_2036_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2036 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2037_pkey ON rankalpha.fact_fin_fundamentals_2037 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2037_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2037 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2037_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2037 USING btree (metric_key, date_key);

CREATE INDEX finfund_2037_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2037 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2038_pkey ON rankalpha.fact_fin_fundamentals_2038 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2038_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2038 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2038_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2038 USING btree (metric_key, date_key);

CREATE INDEX finfund_2038_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2038 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2039_pkey ON rankalpha.fact_fin_fundamentals_2039 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2039_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2039 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2039_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2039 USING btree (metric_key, date_key);

CREATE INDEX finfund_2039_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2039 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2040_pkey ON rankalpha.fact_fin_fundamentals_2040 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2040_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2040 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2040_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2040 USING btree (metric_key, date_key);

CREATE INDEX finfund_2040_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2040 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2041_pkey ON rankalpha.fact_fin_fundamentals_2041 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2041_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2041 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2041_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2041 USING btree (metric_key, date_key);

CREATE INDEX finfund_2041_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2041 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2042_pkey ON rankalpha.fact_fin_fundamentals_2042 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2042_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2042 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2042_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2042 USING btree (metric_key, date_key);

CREATE INDEX finfund_2042_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2042 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2043_pkey ON rankalpha.fact_fin_fundamentals_2043 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2043_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2043 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2043_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2043 USING btree (metric_key, date_key);

CREATE INDEX finfund_2043_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2043 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2044_pkey ON rankalpha.fact_fin_fundamentals_2044 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2044_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2044 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2044_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2044 USING btree (metric_key, date_key);

CREATE INDEX finfund_2044_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2044 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2045_pkey ON rankalpha.fact_fin_fundamentals_2045 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2045_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2045 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2045_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2045 USING btree (metric_key, date_key);

CREATE INDEX finfund_2045_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2045 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2046_pkey ON rankalpha.fact_fin_fundamentals_2046 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2046_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2046 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2046_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2046 USING btree (metric_key, date_key);

CREATE INDEX finfund_2046_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2046 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2047_pkey ON rankalpha.fact_fin_fundamentals_2047 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2047_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2047 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2047_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2047 USING btree (metric_key, date_key);

CREATE INDEX finfund_2047_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2047 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2048_pkey ON rankalpha.fact_fin_fundamentals_2048 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2048_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2048 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2048_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2048 USING btree (metric_key, date_key);

CREATE INDEX finfund_2048_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2048 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2049_pkey ON rankalpha.fact_fin_fundamentals_2049 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2049_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2049 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2049_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2049 USING btree (metric_key, date_key);

CREATE INDEX finfund_2049_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2049 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2050_pkey ON rankalpha.fact_fin_fundamentals_2050 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2050_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2050 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2050_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2050 USING btree (metric_key, date_key);

CREATE INDEX finfund_2050_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2050 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2051_pkey ON rankalpha.fact_fin_fundamentals_2051 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2051_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2051 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2051_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2051 USING btree (metric_key, date_key);

CREATE INDEX finfund_2051_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2051 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2052_pkey ON rankalpha.fact_fin_fundamentals_2052 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2052_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2052 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2052_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2052 USING btree (metric_key, date_key);

CREATE INDEX finfund_2052_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2052 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2053_pkey ON rankalpha.fact_fin_fundamentals_2053 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2053_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2053 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2053_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2053 USING btree (metric_key, date_key);

CREATE INDEX finfund_2053_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2053 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2054_pkey ON rankalpha.fact_fin_fundamentals_2054 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2054_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2054 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2054_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2054 USING btree (metric_key, date_key);

CREATE INDEX finfund_2054_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2054 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2055_pkey ON rankalpha.fact_fin_fundamentals_2055 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2055_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2055 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2055_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2055 USING btree (metric_key, date_key);

CREATE INDEX finfund_2055_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2055 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2056_pkey ON rankalpha.fact_fin_fundamentals_2056 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2056_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2056 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2056_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2056 USING btree (metric_key, date_key);

CREATE INDEX finfund_2056_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2056 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2057_pkey ON rankalpha.fact_fin_fundamentals_2057 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2057_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2057 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2057_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2057 USING btree (metric_key, date_key);

CREATE INDEX finfund_2057_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2057 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2058_pkey ON rankalpha.fact_fin_fundamentals_2058 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2058_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2058 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2058_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2058 USING btree (metric_key, date_key);

CREATE INDEX finfund_2058_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2058 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2059_pkey ON rankalpha.fact_fin_fundamentals_2059 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2059_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2059 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2059_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2059 USING btree (metric_key, date_key);

CREATE INDEX finfund_2059_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2059 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2060_pkey ON rankalpha.fact_fin_fundamentals_2060 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2060_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2060 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2060_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2060 USING btree (metric_key, date_key);

CREATE INDEX finfund_2060_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2060 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2061_pkey ON rankalpha.fact_fin_fundamentals_2061 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2061_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2061 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2061_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2061 USING btree (metric_key, date_key);

CREATE INDEX finfund_2061_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2061 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2062_pkey ON rankalpha.fact_fin_fundamentals_2062 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2062_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2062 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2062_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2062 USING btree (metric_key, date_key);

CREATE INDEX finfund_2062_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2062 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2063_pkey ON rankalpha.fact_fin_fundamentals_2063 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2063_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2063 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2063_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2063 USING btree (metric_key, date_key);

CREATE INDEX finfund_2063_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2063 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2064_pkey ON rankalpha.fact_fin_fundamentals_2064 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2064_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2064 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2064_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2064 USING btree (metric_key, date_key);

CREATE INDEX finfund_2064_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2064 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2065_pkey ON rankalpha.fact_fin_fundamentals_2065 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2065_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2065 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2065_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2065 USING btree (metric_key, date_key);

CREATE INDEX finfund_2065_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2065 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2066_pkey ON rankalpha.fact_fin_fundamentals_2066 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2066_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2066 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2066_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2066 USING btree (metric_key, date_key);

CREATE INDEX finfund_2066_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2066 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2067_pkey ON rankalpha.fact_fin_fundamentals_2067 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2067_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2067 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2067_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2067 USING btree (metric_key, date_key);

CREATE INDEX finfund_2067_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2067 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2068_pkey ON rankalpha.fact_fin_fundamentals_2068 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2068_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2068 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2068_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2068 USING btree (metric_key, date_key);

CREATE INDEX finfund_2068_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2068 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2069_pkey ON rankalpha.fact_fin_fundamentals_2069 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2069_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2069 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2069_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2069 USING btree (metric_key, date_key);

CREATE INDEX finfund_2069_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2069 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2070_pkey ON rankalpha.fact_fin_fundamentals_2070 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2070_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2070 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2070_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2070 USING btree (metric_key, date_key);

CREATE INDEX finfund_2070_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2070 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2071_pkey ON rankalpha.fact_fin_fundamentals_2071 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2071_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2071 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2071_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2071 USING btree (metric_key, date_key);

CREATE INDEX finfund_2071_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2071 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2072_pkey ON rankalpha.fact_fin_fundamentals_2072 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2072_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2072 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2072_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2072 USING btree (metric_key, date_key);

CREATE INDEX finfund_2072_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2072 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2073_pkey ON rankalpha.fact_fin_fundamentals_2073 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2073_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2073 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2073_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2073 USING btree (metric_key, date_key);

CREATE INDEX finfund_2073_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2073 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2074_pkey ON rankalpha.fact_fin_fundamentals_2074 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2074_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2074 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2074_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2074 USING btree (metric_key, date_key);

CREATE INDEX finfund_2074_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2074 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2075_pkey ON rankalpha.fact_fin_fundamentals_2075 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2075_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2075 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2075_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2075 USING btree (metric_key, date_key);

CREATE INDEX finfund_2075_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2075 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2076_pkey ON rankalpha.fact_fin_fundamentals_2076 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2076_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2076 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2076_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2076 USING btree (metric_key, date_key);

CREATE INDEX finfund_2076_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2076 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2077_pkey ON rankalpha.fact_fin_fundamentals_2077 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2077_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2077 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2077_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2077 USING btree (metric_key, date_key);

CREATE INDEX finfund_2077_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2077 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2078_pkey ON rankalpha.fact_fin_fundamentals_2078 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2078_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2078 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2078_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2078 USING btree (metric_key, date_key);

CREATE INDEX finfund_2078_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2078 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2079_pkey ON rankalpha.fact_fin_fundamentals_2079 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2079_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2079 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2079_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2079 USING btree (metric_key, date_key);

CREATE INDEX finfund_2079_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2079 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2080_pkey ON rankalpha.fact_fin_fundamentals_2080 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2080_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2080 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2080_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2080 USING btree (metric_key, date_key);

CREATE INDEX finfund_2080_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2080 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2081_pkey ON rankalpha.fact_fin_fundamentals_2081 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2081_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2081 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2081_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2081 USING btree (metric_key, date_key);

CREATE INDEX finfund_2081_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2081 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2082_pkey ON rankalpha.fact_fin_fundamentals_2082 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2082_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2082 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2082_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2082 USING btree (metric_key, date_key);

CREATE INDEX finfund_2082_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2082 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2083_pkey ON rankalpha.fact_fin_fundamentals_2083 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2083_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2083 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2083_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2083 USING btree (metric_key, date_key);

CREATE INDEX finfund_2083_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2083 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2084_pkey ON rankalpha.fact_fin_fundamentals_2084 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2084_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2084 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2084_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2084 USING btree (metric_key, date_key);

CREATE INDEX finfund_2084_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2084 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2085_pkey ON rankalpha.fact_fin_fundamentals_2085 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2085_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2085 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2085_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2085 USING btree (metric_key, date_key);

CREATE INDEX finfund_2085_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2085 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2086_pkey ON rankalpha.fact_fin_fundamentals_2086 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2086_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2086 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2086_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2086 USING btree (metric_key, date_key);

CREATE INDEX finfund_2086_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2086 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2087_pkey ON rankalpha.fact_fin_fundamentals_2087 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2087_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2087 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2087_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2087 USING btree (metric_key, date_key);

CREATE INDEX finfund_2087_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2087 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2088_pkey ON rankalpha.fact_fin_fundamentals_2088 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2088_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2088 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2088_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2088 USING btree (metric_key, date_key);

CREATE INDEX finfund_2088_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2088 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2089_pkey ON rankalpha.fact_fin_fundamentals_2089 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2089_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2089 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2089_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2089 USING btree (metric_key, date_key);

CREATE INDEX finfund_2089_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2089 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2090_pkey ON rankalpha.fact_fin_fundamentals_2090 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2090_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2090 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2090_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2090 USING btree (metric_key, date_key);

CREATE INDEX finfund_2090_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2090 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2091_pkey ON rankalpha.fact_fin_fundamentals_2091 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2091_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2091 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2091_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2091 USING btree (metric_key, date_key);

CREATE INDEX finfund_2091_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2091 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2092_pkey ON rankalpha.fact_fin_fundamentals_2092 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2092_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2092 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2092_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2092 USING btree (metric_key, date_key);

CREATE INDEX finfund_2092_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2092 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2093_pkey ON rankalpha.fact_fin_fundamentals_2093 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2093_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2093 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2093_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2093 USING btree (metric_key, date_key);

CREATE INDEX finfund_2093_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2093 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2094_pkey ON rankalpha.fact_fin_fundamentals_2094 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2094_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2094 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2094_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2094 USING btree (metric_key, date_key);

CREATE INDEX finfund_2094_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2094 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2095_pkey ON rankalpha.fact_fin_fundamentals_2095 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2095_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2095 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2095_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2095 USING btree (metric_key, date_key);

CREATE INDEX finfund_2095_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2095 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2096_pkey ON rankalpha.fact_fin_fundamentals_2096 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2096_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2096 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2096_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2096 USING btree (metric_key, date_key);

CREATE INDEX finfund_2096_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2096 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2097_pkey ON rankalpha.fact_fin_fundamentals_2097 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2097_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2097 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2097_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2097 USING btree (metric_key, date_key);

CREATE INDEX finfund_2097_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2097 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2098_pkey ON rankalpha.fact_fin_fundamentals_2098 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2098_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2098 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2098_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2098 USING btree (metric_key, date_key);

CREATE INDEX finfund_2098_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2098 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2099_pkey ON rankalpha.fact_fin_fundamentals_2099 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2099_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2099 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2099_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2099 USING btree (metric_key, date_key);

CREATE INDEX finfund_2099_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2099 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_2100_pkey ON rankalpha.fact_fin_fundamentals_2100 USING btree (date_key, stock_key, metric_key);

CREATE INDEX fact_fin_fundamentals_2100_stock_key_metric_key_idx ON rankalpha.fact_fin_fundamentals_2100 USING btree (stock_key, metric_key);

CREATE INDEX finfund_2100_mk_dk_idx ON rankalpha.fact_fin_fundamentals_2100 USING btree (metric_key, date_key);

CREATE INDEX finfund_2100_sk_mk_idx ON rankalpha.fact_fin_fundamentals_2100 USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fin_fundamentals_default_pkey ON rankalpha.fact_fin_fundamentals_default USING btree (date_key, stock_key, metric_key);

CREATE INDEX finfund__mk_dk_idx ON rankalpha.fact_fin_fundamentals_default USING btree (metric_key, date_key);

CREATE INDEX finfund__sk_mk_idx ON rankalpha.fact_fin_fundamentals_default USING btree (stock_key, metric_key);

CREATE UNIQUE INDEX fact_fx_rate_pkey ON rankalpha.fact_fx_rate USING btree (date_key, from_ccy, to_ccy);

CREATE UNIQUE INDEX fact_iv_pkey ON rankalpha.fact_iv_surface USING btree (date_key, stock_key, tenor_key);

CREATE UNIQUE INDEX fact_news_articles_pkey ON ONLY rankalpha.fact_news_articles USING btree (article_date, article_id);

CREATE UNIQUE INDEX fact_news_articles_2020_pkey ON rankalpha.fact_news_articles_2020 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2020_stock_date ON rankalpha.fact_news_articles_2020 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2021_pkey ON rankalpha.fact_news_articles_2021 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2021_stock_date ON rankalpha.fact_news_articles_2021 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2022_pkey ON rankalpha.fact_news_articles_2022 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2022_stock_date ON rankalpha.fact_news_articles_2022 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2023_pkey ON rankalpha.fact_news_articles_2023 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2023_stock_date ON rankalpha.fact_news_articles_2023 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2024_pkey ON rankalpha.fact_news_articles_2024 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2024_stock_date ON rankalpha.fact_news_articles_2024 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2025_pkey ON rankalpha.fact_news_articles_2025 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2025_stock_date ON rankalpha.fact_news_articles_2025 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2026_pkey ON rankalpha.fact_news_articles_2026 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2026_stock_date ON rankalpha.fact_news_articles_2026 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2027_pkey ON rankalpha.fact_news_articles_2027 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2027_stock_date ON rankalpha.fact_news_articles_2027 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2028_pkey ON rankalpha.fact_news_articles_2028 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2028_stock_date ON rankalpha.fact_news_articles_2028 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2029_pkey ON rankalpha.fact_news_articles_2029 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2029_stock_date ON rankalpha.fact_news_articles_2029 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2030_pkey ON rankalpha.fact_news_articles_2030 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2030_stock_date ON rankalpha.fact_news_articles_2030 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2031_pkey ON rankalpha.fact_news_articles_2031 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2031_stock_date ON rankalpha.fact_news_articles_2031 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2032_pkey ON rankalpha.fact_news_articles_2032 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2032_stock_date ON rankalpha.fact_news_articles_2032 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2033_pkey ON rankalpha.fact_news_articles_2033 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2033_stock_date ON rankalpha.fact_news_articles_2033 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2034_pkey ON rankalpha.fact_news_articles_2034 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2034_stock_date ON rankalpha.fact_news_articles_2034 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2035_pkey ON rankalpha.fact_news_articles_2035 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2035_stock_date ON rankalpha.fact_news_articles_2035 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2036_pkey ON rankalpha.fact_news_articles_2036 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2036_stock_date ON rankalpha.fact_news_articles_2036 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2037_pkey ON rankalpha.fact_news_articles_2037 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2037_stock_date ON rankalpha.fact_news_articles_2037 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2038_pkey ON rankalpha.fact_news_articles_2038 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2038_stock_date ON rankalpha.fact_news_articles_2038 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2039_pkey ON rankalpha.fact_news_articles_2039 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2039_stock_date ON rankalpha.fact_news_articles_2039 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2040_pkey ON rankalpha.fact_news_articles_2040 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2040_stock_date ON rankalpha.fact_news_articles_2040 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2041_pkey ON rankalpha.fact_news_articles_2041 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2041_stock_date ON rankalpha.fact_news_articles_2041 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2042_pkey ON rankalpha.fact_news_articles_2042 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2042_stock_date ON rankalpha.fact_news_articles_2042 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2043_pkey ON rankalpha.fact_news_articles_2043 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2043_stock_date ON rankalpha.fact_news_articles_2043 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2044_pkey ON rankalpha.fact_news_articles_2044 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2044_stock_date ON rankalpha.fact_news_articles_2044 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2045_pkey ON rankalpha.fact_news_articles_2045 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2045_stock_date ON rankalpha.fact_news_articles_2045 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2046_pkey ON rankalpha.fact_news_articles_2046 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2046_stock_date ON rankalpha.fact_news_articles_2046 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2047_pkey ON rankalpha.fact_news_articles_2047 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2047_stock_date ON rankalpha.fact_news_articles_2047 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2048_pkey ON rankalpha.fact_news_articles_2048 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2048_stock_date ON rankalpha.fact_news_articles_2048 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2049_pkey ON rankalpha.fact_news_articles_2049 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2049_stock_date ON rankalpha.fact_news_articles_2049 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2050_pkey ON rankalpha.fact_news_articles_2050 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2050_stock_date ON rankalpha.fact_news_articles_2050 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2051_pkey ON rankalpha.fact_news_articles_2051 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2051_stock_date ON rankalpha.fact_news_articles_2051 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2052_pkey ON rankalpha.fact_news_articles_2052 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2052_stock_date ON rankalpha.fact_news_articles_2052 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2053_pkey ON rankalpha.fact_news_articles_2053 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2053_stock_date ON rankalpha.fact_news_articles_2053 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2054_pkey ON rankalpha.fact_news_articles_2054 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2054_stock_date ON rankalpha.fact_news_articles_2054 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2055_pkey ON rankalpha.fact_news_articles_2055 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2055_stock_date ON rankalpha.fact_news_articles_2055 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2056_pkey ON rankalpha.fact_news_articles_2056 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2056_stock_date ON rankalpha.fact_news_articles_2056 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2057_pkey ON rankalpha.fact_news_articles_2057 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2057_stock_date ON rankalpha.fact_news_articles_2057 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2058_pkey ON rankalpha.fact_news_articles_2058 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2058_stock_date ON rankalpha.fact_news_articles_2058 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2059_pkey ON rankalpha.fact_news_articles_2059 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2059_stock_date ON rankalpha.fact_news_articles_2059 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2060_pkey ON rankalpha.fact_news_articles_2060 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2060_stock_date ON rankalpha.fact_news_articles_2060 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2061_pkey ON rankalpha.fact_news_articles_2061 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2061_stock_date ON rankalpha.fact_news_articles_2061 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2062_pkey ON rankalpha.fact_news_articles_2062 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2062_stock_date ON rankalpha.fact_news_articles_2062 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2063_pkey ON rankalpha.fact_news_articles_2063 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2063_stock_date ON rankalpha.fact_news_articles_2063 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2064_pkey ON rankalpha.fact_news_articles_2064 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2064_stock_date ON rankalpha.fact_news_articles_2064 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2065_pkey ON rankalpha.fact_news_articles_2065 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2065_stock_date ON rankalpha.fact_news_articles_2065 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2066_pkey ON rankalpha.fact_news_articles_2066 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2066_stock_date ON rankalpha.fact_news_articles_2066 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2067_pkey ON rankalpha.fact_news_articles_2067 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2067_stock_date ON rankalpha.fact_news_articles_2067 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2068_pkey ON rankalpha.fact_news_articles_2068 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2068_stock_date ON rankalpha.fact_news_articles_2068 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2069_pkey ON rankalpha.fact_news_articles_2069 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2069_stock_date ON rankalpha.fact_news_articles_2069 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2070_pkey ON rankalpha.fact_news_articles_2070 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2070_stock_date ON rankalpha.fact_news_articles_2070 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2071_pkey ON rankalpha.fact_news_articles_2071 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2071_stock_date ON rankalpha.fact_news_articles_2071 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2072_pkey ON rankalpha.fact_news_articles_2072 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2072_stock_date ON rankalpha.fact_news_articles_2072 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2073_pkey ON rankalpha.fact_news_articles_2073 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2073_stock_date ON rankalpha.fact_news_articles_2073 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2074_pkey ON rankalpha.fact_news_articles_2074 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2074_stock_date ON rankalpha.fact_news_articles_2074 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2075_pkey ON rankalpha.fact_news_articles_2075 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2075_stock_date ON rankalpha.fact_news_articles_2075 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2076_pkey ON rankalpha.fact_news_articles_2076 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2076_stock_date ON rankalpha.fact_news_articles_2076 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2077_pkey ON rankalpha.fact_news_articles_2077 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2077_stock_date ON rankalpha.fact_news_articles_2077 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2078_pkey ON rankalpha.fact_news_articles_2078 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2078_stock_date ON rankalpha.fact_news_articles_2078 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2079_pkey ON rankalpha.fact_news_articles_2079 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2079_stock_date ON rankalpha.fact_news_articles_2079 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2080_pkey ON rankalpha.fact_news_articles_2080 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2080_stock_date ON rankalpha.fact_news_articles_2080 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2081_pkey ON rankalpha.fact_news_articles_2081 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2081_stock_date ON rankalpha.fact_news_articles_2081 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2082_pkey ON rankalpha.fact_news_articles_2082 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2082_stock_date ON rankalpha.fact_news_articles_2082 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2083_pkey ON rankalpha.fact_news_articles_2083 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2083_stock_date ON rankalpha.fact_news_articles_2083 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2084_pkey ON rankalpha.fact_news_articles_2084 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2084_stock_date ON rankalpha.fact_news_articles_2084 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2085_pkey ON rankalpha.fact_news_articles_2085 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2085_stock_date ON rankalpha.fact_news_articles_2085 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2086_pkey ON rankalpha.fact_news_articles_2086 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2086_stock_date ON rankalpha.fact_news_articles_2086 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2087_pkey ON rankalpha.fact_news_articles_2087 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2087_stock_date ON rankalpha.fact_news_articles_2087 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2088_pkey ON rankalpha.fact_news_articles_2088 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2088_stock_date ON rankalpha.fact_news_articles_2088 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2089_pkey ON rankalpha.fact_news_articles_2089 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2089_stock_date ON rankalpha.fact_news_articles_2089 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2090_pkey ON rankalpha.fact_news_articles_2090 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2090_stock_date ON rankalpha.fact_news_articles_2090 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2091_pkey ON rankalpha.fact_news_articles_2091 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2091_stock_date ON rankalpha.fact_news_articles_2091 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2092_pkey ON rankalpha.fact_news_articles_2092 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2092_stock_date ON rankalpha.fact_news_articles_2092 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2093_pkey ON rankalpha.fact_news_articles_2093 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2093_stock_date ON rankalpha.fact_news_articles_2093 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2094_pkey ON rankalpha.fact_news_articles_2094 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2094_stock_date ON rankalpha.fact_news_articles_2094 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2095_pkey ON rankalpha.fact_news_articles_2095 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2095_stock_date ON rankalpha.fact_news_articles_2095 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2096_pkey ON rankalpha.fact_news_articles_2096 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2096_stock_date ON rankalpha.fact_news_articles_2096 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2097_pkey ON rankalpha.fact_news_articles_2097 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2097_stock_date ON rankalpha.fact_news_articles_2097 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2098_pkey ON rankalpha.fact_news_articles_2098 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2098_stock_date ON rankalpha.fact_news_articles_2098 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2099_pkey ON rankalpha.fact_news_articles_2099 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2099_stock_date ON rankalpha.fact_news_articles_2099 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_2100_pkey ON rankalpha.fact_news_articles_2100 USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_2100_stock_date ON rankalpha.fact_news_articles_2100 USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_articles_default_pkey ON rankalpha.fact_news_articles_default USING btree (article_date, article_id);

CREATE INDEX idx_fact_news_articles_default_stock_date ON rankalpha.fact_news_articles_default USING btree (stock_key, article_date);

CREATE UNIQUE INDEX fact_news_sentiment_pkey ON rankalpha.fact_news_sentiment USING btree (article_id);

CREATE INDEX idx_fact_news_sentiment_score ON rankalpha.fact_news_sentiment USING btree (sentiment_score);

CREATE UNIQUE INDEX fact_portfolio_factor_exposure_pkey ON rankalpha.fact_portfolio_factor_exposure USING btree (date_key, portfolio_id, factor_key);

CREATE UNIQUE INDEX fact_portfolio_nav_pkey ON rankalpha.fact_portfolio_nav USING btree (date_key, portfolio_id);

CREATE UNIQUE INDEX fact_portfolio_pnl_pkey ON rankalpha.fact_portfolio_pnl USING btree (date_key, portfolio_id);

CREATE UNIQUE INDEX fact_portfolio_position_hist_pkey ON rankalpha.fact_portfolio_position_hist USING btree (effective_date, portfolio_id, stock_key);

CREATE UNIQUE INDEX fact_portfolio_risk_pkey ON rankalpha.fact_portfolio_risk USING btree (date_key, portfolio_id, metric_name);

CREATE UNIQUE INDEX fact_portfolio_scenario_pnl_pkey ON rankalpha.fact_portfolio_scenario_pnl USING btree (date_key, portfolio_id, scenario_key);

CREATE UNIQUE INDEX fact_portfolio_trade_pkey ON rankalpha.fact_portfolio_trade USING btree (trade_id);

CREATE INDEX idx_trade_portfolio_date ON rankalpha.fact_portfolio_trade USING btree (portfolio_id, exec_ts DESC);

CREATE UNIQUE INDEX fact_portfolio_var_pkey ON rankalpha.fact_portfolio_var USING btree (date_key, portfolio_id, var_method_key, horizon_days, confidence_pct);

CREATE UNIQUE INDEX fact_rfr_pkey ON rankalpha.fact_risk_free_rate USING btree (date_key, tenor_key);

CREATE UNIQUE INDEX fact_score_history_pkey ON ONLY rankalpha.fact_score_history USING btree (date_key, fact_id);

CREATE INDEX idx_fact_score_history_score_type_key ON ONLY rankalpha.fact_score_history USING btree (score_type_key);

CREATE INDEX idx_fact_score_history_source_key ON ONLY rankalpha.fact_score_history USING btree (source_key);

CREATE INDEX idx_fact_score_history_stock_key ON ONLY rankalpha.fact_score_history USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_1997_pkey ON rankalpha.fact_score_history_1997 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_1997_score_type_key_idx ON rankalpha.fact_score_history_1997 USING btree (score_type_key);

CREATE INDEX fact_score_history_1997_source_key_idx ON rankalpha.fact_score_history_1997 USING btree (source_key);

CREATE INDEX fact_score_history_1997_stock_key_idx ON rankalpha.fact_score_history_1997 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_1998_pkey ON rankalpha.fact_score_history_1998 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_1998_score_type_key_idx ON rankalpha.fact_score_history_1998 USING btree (score_type_key);

CREATE INDEX fact_score_history_1998_source_key_idx ON rankalpha.fact_score_history_1998 USING btree (source_key);

CREATE INDEX fact_score_history_1998_stock_key_idx ON rankalpha.fact_score_history_1998 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_1999_pkey ON rankalpha.fact_score_history_1999 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_1999_score_type_key_idx ON rankalpha.fact_score_history_1999 USING btree (score_type_key);

CREATE INDEX fact_score_history_1999_source_key_idx ON rankalpha.fact_score_history_1999 USING btree (source_key);

CREATE INDEX fact_score_history_1999_stock_key_idx ON rankalpha.fact_score_history_1999 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2000_pkey ON rankalpha.fact_score_history_2000 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2000_score_type_key_idx ON rankalpha.fact_score_history_2000 USING btree (score_type_key);

CREATE INDEX fact_score_history_2000_source_key_idx ON rankalpha.fact_score_history_2000 USING btree (source_key);

CREATE INDEX fact_score_history_2000_stock_key_idx ON rankalpha.fact_score_history_2000 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2001_pkey ON rankalpha.fact_score_history_2001 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2001_score_type_key_idx ON rankalpha.fact_score_history_2001 USING btree (score_type_key);

CREATE INDEX fact_score_history_2001_source_key_idx ON rankalpha.fact_score_history_2001 USING btree (source_key);

CREATE INDEX fact_score_history_2001_stock_key_idx ON rankalpha.fact_score_history_2001 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2002_pkey ON rankalpha.fact_score_history_2002 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2002_score_type_key_idx ON rankalpha.fact_score_history_2002 USING btree (score_type_key);

CREATE INDEX fact_score_history_2002_source_key_idx ON rankalpha.fact_score_history_2002 USING btree (source_key);

CREATE INDEX fact_score_history_2002_stock_key_idx ON rankalpha.fact_score_history_2002 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2003_pkey ON rankalpha.fact_score_history_2003 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2003_score_type_key_idx ON rankalpha.fact_score_history_2003 USING btree (score_type_key);

CREATE INDEX fact_score_history_2003_source_key_idx ON rankalpha.fact_score_history_2003 USING btree (source_key);

CREATE INDEX fact_score_history_2003_stock_key_idx ON rankalpha.fact_score_history_2003 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2004_pkey ON rankalpha.fact_score_history_2004 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2004_score_type_key_idx ON rankalpha.fact_score_history_2004 USING btree (score_type_key);

CREATE INDEX fact_score_history_2004_source_key_idx ON rankalpha.fact_score_history_2004 USING btree (source_key);

CREATE INDEX fact_score_history_2004_stock_key_idx ON rankalpha.fact_score_history_2004 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2005_pkey ON rankalpha.fact_score_history_2005 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2005_score_type_key_idx ON rankalpha.fact_score_history_2005 USING btree (score_type_key);

CREATE INDEX fact_score_history_2005_source_key_idx ON rankalpha.fact_score_history_2005 USING btree (source_key);

CREATE INDEX fact_score_history_2005_stock_key_idx ON rankalpha.fact_score_history_2005 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2006_pkey ON rankalpha.fact_score_history_2006 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2006_score_type_key_idx ON rankalpha.fact_score_history_2006 USING btree (score_type_key);

CREATE INDEX fact_score_history_2006_source_key_idx ON rankalpha.fact_score_history_2006 USING btree (source_key);

CREATE INDEX fact_score_history_2006_stock_key_idx ON rankalpha.fact_score_history_2006 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2007_pkey ON rankalpha.fact_score_history_2007 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2007_score_type_key_idx ON rankalpha.fact_score_history_2007 USING btree (score_type_key);

CREATE INDEX fact_score_history_2007_source_key_idx ON rankalpha.fact_score_history_2007 USING btree (source_key);

CREATE INDEX fact_score_history_2007_stock_key_idx ON rankalpha.fact_score_history_2007 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2008_pkey ON rankalpha.fact_score_history_2008 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2008_score_type_key_idx ON rankalpha.fact_score_history_2008 USING btree (score_type_key);

CREATE INDEX fact_score_history_2008_source_key_idx ON rankalpha.fact_score_history_2008 USING btree (source_key);

CREATE INDEX fact_score_history_2008_stock_key_idx ON rankalpha.fact_score_history_2008 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2009_pkey ON rankalpha.fact_score_history_2009 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2009_score_type_key_idx ON rankalpha.fact_score_history_2009 USING btree (score_type_key);

CREATE INDEX fact_score_history_2009_source_key_idx ON rankalpha.fact_score_history_2009 USING btree (source_key);

CREATE INDEX fact_score_history_2009_stock_key_idx ON rankalpha.fact_score_history_2009 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2010_pkey ON rankalpha.fact_score_history_2010 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2010_score_type_key_idx ON rankalpha.fact_score_history_2010 USING btree (score_type_key);

CREATE INDEX fact_score_history_2010_source_key_idx ON rankalpha.fact_score_history_2010 USING btree (source_key);

CREATE INDEX fact_score_history_2010_stock_key_idx ON rankalpha.fact_score_history_2010 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2011_pkey ON rankalpha.fact_score_history_2011 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2011_score_type_key_idx ON rankalpha.fact_score_history_2011 USING btree (score_type_key);

CREATE INDEX fact_score_history_2011_source_key_idx ON rankalpha.fact_score_history_2011 USING btree (source_key);

CREATE INDEX fact_score_history_2011_stock_key_idx ON rankalpha.fact_score_history_2011 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2012_pkey ON rankalpha.fact_score_history_2012 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2012_score_type_key_idx ON rankalpha.fact_score_history_2012 USING btree (score_type_key);

CREATE INDEX fact_score_history_2012_source_key_idx ON rankalpha.fact_score_history_2012 USING btree (source_key);

CREATE INDEX fact_score_history_2012_stock_key_idx ON rankalpha.fact_score_history_2012 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2013_pkey ON rankalpha.fact_score_history_2013 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2013_score_type_key_idx ON rankalpha.fact_score_history_2013 USING btree (score_type_key);

CREATE INDEX fact_score_history_2013_source_key_idx ON rankalpha.fact_score_history_2013 USING btree (source_key);

CREATE INDEX fact_score_history_2013_stock_key_idx ON rankalpha.fact_score_history_2013 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2014_pkey ON rankalpha.fact_score_history_2014 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2014_score_type_key_idx ON rankalpha.fact_score_history_2014 USING btree (score_type_key);

CREATE INDEX fact_score_history_2014_source_key_idx ON rankalpha.fact_score_history_2014 USING btree (source_key);

CREATE INDEX fact_score_history_2014_stock_key_idx ON rankalpha.fact_score_history_2014 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2015_pkey ON rankalpha.fact_score_history_2015 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2015_score_type_key_idx ON rankalpha.fact_score_history_2015 USING btree (score_type_key);

CREATE INDEX fact_score_history_2015_source_key_idx ON rankalpha.fact_score_history_2015 USING btree (source_key);

CREATE INDEX fact_score_history_2015_stock_key_idx ON rankalpha.fact_score_history_2015 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2016_pkey ON rankalpha.fact_score_history_2016 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2016_score_type_key_idx ON rankalpha.fact_score_history_2016 USING btree (score_type_key);

CREATE INDEX fact_score_history_2016_source_key_idx ON rankalpha.fact_score_history_2016 USING btree (source_key);

CREATE INDEX fact_score_history_2016_stock_key_idx ON rankalpha.fact_score_history_2016 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2017_pkey ON rankalpha.fact_score_history_2017 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2017_score_type_key_idx ON rankalpha.fact_score_history_2017 USING btree (score_type_key);

CREATE INDEX fact_score_history_2017_source_key_idx ON rankalpha.fact_score_history_2017 USING btree (source_key);

CREATE INDEX fact_score_history_2017_stock_key_idx ON rankalpha.fact_score_history_2017 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2018_pkey ON rankalpha.fact_score_history_2018 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2018_score_type_key_idx ON rankalpha.fact_score_history_2018 USING btree (score_type_key);

CREATE INDEX fact_score_history_2018_source_key_idx ON rankalpha.fact_score_history_2018 USING btree (source_key);

CREATE INDEX fact_score_history_2018_stock_key_idx ON rankalpha.fact_score_history_2018 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2019_pkey ON rankalpha.fact_score_history_2019 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2019_score_type_key_idx ON rankalpha.fact_score_history_2019 USING btree (score_type_key);

CREATE INDEX fact_score_history_2019_source_key_idx ON rankalpha.fact_score_history_2019 USING btree (source_key);

CREATE INDEX fact_score_history_2019_stock_key_idx ON rankalpha.fact_score_history_2019 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2020_pkey ON rankalpha.fact_score_history_2020 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2020_score_type_key_idx ON rankalpha.fact_score_history_2020 USING btree (score_type_key);

CREATE INDEX fact_score_history_2020_source_key_idx ON rankalpha.fact_score_history_2020 USING btree (source_key);

CREATE INDEX fact_score_history_2020_stock_key_idx ON rankalpha.fact_score_history_2020 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2021_pkey ON rankalpha.fact_score_history_2021 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2021_score_type_key_idx ON rankalpha.fact_score_history_2021 USING btree (score_type_key);

CREATE INDEX fact_score_history_2021_source_key_idx ON rankalpha.fact_score_history_2021 USING btree (source_key);

CREATE INDEX fact_score_history_2021_stock_key_idx ON rankalpha.fact_score_history_2021 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2022_pkey ON rankalpha.fact_score_history_2022 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2022_score_type_key_idx ON rankalpha.fact_score_history_2022 USING btree (score_type_key);

CREATE INDEX fact_score_history_2022_source_key_idx ON rankalpha.fact_score_history_2022 USING btree (source_key);

CREATE INDEX fact_score_history_2022_stock_key_idx ON rankalpha.fact_score_history_2022 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2023_pkey ON rankalpha.fact_score_history_2023 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2023_score_type_key_idx ON rankalpha.fact_score_history_2023 USING btree (score_type_key);

CREATE INDEX fact_score_history_2023_source_key_idx ON rankalpha.fact_score_history_2023 USING btree (source_key);

CREATE INDEX fact_score_history_2023_stock_key_idx ON rankalpha.fact_score_history_2023 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2024_pkey ON rankalpha.fact_score_history_2024 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2024_score_type_key_idx ON rankalpha.fact_score_history_2024 USING btree (score_type_key);

CREATE INDEX fact_score_history_2024_source_key_idx ON rankalpha.fact_score_history_2024 USING btree (source_key);

CREATE INDEX fact_score_history_2024_stock_key_idx ON rankalpha.fact_score_history_2024 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2025_pkey ON rankalpha.fact_score_history_2025 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2025_score_type_key_idx ON rankalpha.fact_score_history_2025 USING btree (score_type_key);

CREATE INDEX fact_score_history_2025_source_key_idx ON rankalpha.fact_score_history_2025 USING btree (source_key);

CREATE INDEX fact_score_history_2025_stock_key_idx ON rankalpha.fact_score_history_2025 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2026_pkey ON rankalpha.fact_score_history_2026 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2026_score_type_key_idx ON rankalpha.fact_score_history_2026 USING btree (score_type_key);

CREATE INDEX fact_score_history_2026_source_key_idx ON rankalpha.fact_score_history_2026 USING btree (source_key);

CREATE INDEX fact_score_history_2026_stock_key_idx ON rankalpha.fact_score_history_2026 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2027_pkey ON rankalpha.fact_score_history_2027 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2027_score_type_key_idx ON rankalpha.fact_score_history_2027 USING btree (score_type_key);

CREATE INDEX fact_score_history_2027_source_key_idx ON rankalpha.fact_score_history_2027 USING btree (source_key);

CREATE INDEX fact_score_history_2027_stock_key_idx ON rankalpha.fact_score_history_2027 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2028_pkey ON rankalpha.fact_score_history_2028 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2028_score_type_key_idx ON rankalpha.fact_score_history_2028 USING btree (score_type_key);

CREATE INDEX fact_score_history_2028_source_key_idx ON rankalpha.fact_score_history_2028 USING btree (source_key);

CREATE INDEX fact_score_history_2028_stock_key_idx ON rankalpha.fact_score_history_2028 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2029_pkey ON rankalpha.fact_score_history_2029 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2029_score_type_key_idx ON rankalpha.fact_score_history_2029 USING btree (score_type_key);

CREATE INDEX fact_score_history_2029_source_key_idx ON rankalpha.fact_score_history_2029 USING btree (source_key);

CREATE INDEX fact_score_history_2029_stock_key_idx ON rankalpha.fact_score_history_2029 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2030_pkey ON rankalpha.fact_score_history_2030 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2030_score_type_key_idx ON rankalpha.fact_score_history_2030 USING btree (score_type_key);

CREATE INDEX fact_score_history_2030_source_key_idx ON rankalpha.fact_score_history_2030 USING btree (source_key);

CREATE INDEX fact_score_history_2030_stock_key_idx ON rankalpha.fact_score_history_2030 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2031_pkey ON rankalpha.fact_score_history_2031 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2031_score_type_key_idx ON rankalpha.fact_score_history_2031 USING btree (score_type_key);

CREATE INDEX fact_score_history_2031_source_key_idx ON rankalpha.fact_score_history_2031 USING btree (source_key);

CREATE INDEX fact_score_history_2031_stock_key_idx ON rankalpha.fact_score_history_2031 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2032_pkey ON rankalpha.fact_score_history_2032 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2032_score_type_key_idx ON rankalpha.fact_score_history_2032 USING btree (score_type_key);

CREATE INDEX fact_score_history_2032_source_key_idx ON rankalpha.fact_score_history_2032 USING btree (source_key);

CREATE INDEX fact_score_history_2032_stock_key_idx ON rankalpha.fact_score_history_2032 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2033_pkey ON rankalpha.fact_score_history_2033 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2033_score_type_key_idx ON rankalpha.fact_score_history_2033 USING btree (score_type_key);

CREATE INDEX fact_score_history_2033_source_key_idx ON rankalpha.fact_score_history_2033 USING btree (source_key);

CREATE INDEX fact_score_history_2033_stock_key_idx ON rankalpha.fact_score_history_2033 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2034_pkey ON rankalpha.fact_score_history_2034 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2034_score_type_key_idx ON rankalpha.fact_score_history_2034 USING btree (score_type_key);

CREATE INDEX fact_score_history_2034_source_key_idx ON rankalpha.fact_score_history_2034 USING btree (source_key);

CREATE INDEX fact_score_history_2034_stock_key_idx ON rankalpha.fact_score_history_2034 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2035_pkey ON rankalpha.fact_score_history_2035 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2035_score_type_key_idx ON rankalpha.fact_score_history_2035 USING btree (score_type_key);

CREATE INDEX fact_score_history_2035_source_key_idx ON rankalpha.fact_score_history_2035 USING btree (source_key);

CREATE INDEX fact_score_history_2035_stock_key_idx ON rankalpha.fact_score_history_2035 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2036_pkey ON rankalpha.fact_score_history_2036 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2036_score_type_key_idx ON rankalpha.fact_score_history_2036 USING btree (score_type_key);

CREATE INDEX fact_score_history_2036_source_key_idx ON rankalpha.fact_score_history_2036 USING btree (source_key);

CREATE INDEX fact_score_history_2036_stock_key_idx ON rankalpha.fact_score_history_2036 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2037_pkey ON rankalpha.fact_score_history_2037 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2037_score_type_key_idx ON rankalpha.fact_score_history_2037 USING btree (score_type_key);

CREATE INDEX fact_score_history_2037_source_key_idx ON rankalpha.fact_score_history_2037 USING btree (source_key);

CREATE INDEX fact_score_history_2037_stock_key_idx ON rankalpha.fact_score_history_2037 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2038_pkey ON rankalpha.fact_score_history_2038 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2038_score_type_key_idx ON rankalpha.fact_score_history_2038 USING btree (score_type_key);

CREATE INDEX fact_score_history_2038_source_key_idx ON rankalpha.fact_score_history_2038 USING btree (source_key);

CREATE INDEX fact_score_history_2038_stock_key_idx ON rankalpha.fact_score_history_2038 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2039_pkey ON rankalpha.fact_score_history_2039 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2039_score_type_key_idx ON rankalpha.fact_score_history_2039 USING btree (score_type_key);

CREATE INDEX fact_score_history_2039_source_key_idx ON rankalpha.fact_score_history_2039 USING btree (source_key);

CREATE INDEX fact_score_history_2039_stock_key_idx ON rankalpha.fact_score_history_2039 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2040_pkey ON rankalpha.fact_score_history_2040 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2040_score_type_key_idx ON rankalpha.fact_score_history_2040 USING btree (score_type_key);

CREATE INDEX fact_score_history_2040_source_key_idx ON rankalpha.fact_score_history_2040 USING btree (source_key);

CREATE INDEX fact_score_history_2040_stock_key_idx ON rankalpha.fact_score_history_2040 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2041_pkey ON rankalpha.fact_score_history_2041 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2041_score_type_key_idx ON rankalpha.fact_score_history_2041 USING btree (score_type_key);

CREATE INDEX fact_score_history_2041_source_key_idx ON rankalpha.fact_score_history_2041 USING btree (source_key);

CREATE INDEX fact_score_history_2041_stock_key_idx ON rankalpha.fact_score_history_2041 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2042_pkey ON rankalpha.fact_score_history_2042 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2042_score_type_key_idx ON rankalpha.fact_score_history_2042 USING btree (score_type_key);

CREATE INDEX fact_score_history_2042_source_key_idx ON rankalpha.fact_score_history_2042 USING btree (source_key);

CREATE INDEX fact_score_history_2042_stock_key_idx ON rankalpha.fact_score_history_2042 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2043_pkey ON rankalpha.fact_score_history_2043 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2043_score_type_key_idx ON rankalpha.fact_score_history_2043 USING btree (score_type_key);

CREATE INDEX fact_score_history_2043_source_key_idx ON rankalpha.fact_score_history_2043 USING btree (source_key);

CREATE INDEX fact_score_history_2043_stock_key_idx ON rankalpha.fact_score_history_2043 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2044_pkey ON rankalpha.fact_score_history_2044 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2044_score_type_key_idx ON rankalpha.fact_score_history_2044 USING btree (score_type_key);

CREATE INDEX fact_score_history_2044_source_key_idx ON rankalpha.fact_score_history_2044 USING btree (source_key);

CREATE INDEX fact_score_history_2044_stock_key_idx ON rankalpha.fact_score_history_2044 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2045_pkey ON rankalpha.fact_score_history_2045 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2045_score_type_key_idx ON rankalpha.fact_score_history_2045 USING btree (score_type_key);

CREATE INDEX fact_score_history_2045_source_key_idx ON rankalpha.fact_score_history_2045 USING btree (source_key);

CREATE INDEX fact_score_history_2045_stock_key_idx ON rankalpha.fact_score_history_2045 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2046_pkey ON rankalpha.fact_score_history_2046 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2046_score_type_key_idx ON rankalpha.fact_score_history_2046 USING btree (score_type_key);

CREATE INDEX fact_score_history_2046_source_key_idx ON rankalpha.fact_score_history_2046 USING btree (source_key);

CREATE INDEX fact_score_history_2046_stock_key_idx ON rankalpha.fact_score_history_2046 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2047_pkey ON rankalpha.fact_score_history_2047 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2047_score_type_key_idx ON rankalpha.fact_score_history_2047 USING btree (score_type_key);

CREATE INDEX fact_score_history_2047_source_key_idx ON rankalpha.fact_score_history_2047 USING btree (source_key);

CREATE INDEX fact_score_history_2047_stock_key_idx ON rankalpha.fact_score_history_2047 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2048_pkey ON rankalpha.fact_score_history_2048 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2048_score_type_key_idx ON rankalpha.fact_score_history_2048 USING btree (score_type_key);

CREATE INDEX fact_score_history_2048_source_key_idx ON rankalpha.fact_score_history_2048 USING btree (source_key);

CREATE INDEX fact_score_history_2048_stock_key_idx ON rankalpha.fact_score_history_2048 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2049_pkey ON rankalpha.fact_score_history_2049 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2049_score_type_key_idx ON rankalpha.fact_score_history_2049 USING btree (score_type_key);

CREATE INDEX fact_score_history_2049_source_key_idx ON rankalpha.fact_score_history_2049 USING btree (source_key);

CREATE INDEX fact_score_history_2049_stock_key_idx ON rankalpha.fact_score_history_2049 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2050_pkey ON rankalpha.fact_score_history_2050 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2050_score_type_key_idx ON rankalpha.fact_score_history_2050 USING btree (score_type_key);

CREATE INDEX fact_score_history_2050_source_key_idx ON rankalpha.fact_score_history_2050 USING btree (source_key);

CREATE INDEX fact_score_history_2050_stock_key_idx ON rankalpha.fact_score_history_2050 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2051_pkey ON rankalpha.fact_score_history_2051 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2051_score_type_key_idx ON rankalpha.fact_score_history_2051 USING btree (score_type_key);

CREATE INDEX fact_score_history_2051_source_key_idx ON rankalpha.fact_score_history_2051 USING btree (source_key);

CREATE INDEX fact_score_history_2051_stock_key_idx ON rankalpha.fact_score_history_2051 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2052_pkey ON rankalpha.fact_score_history_2052 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2052_score_type_key_idx ON rankalpha.fact_score_history_2052 USING btree (score_type_key);

CREATE INDEX fact_score_history_2052_source_key_idx ON rankalpha.fact_score_history_2052 USING btree (source_key);

CREATE INDEX fact_score_history_2052_stock_key_idx ON rankalpha.fact_score_history_2052 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2053_pkey ON rankalpha.fact_score_history_2053 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2053_score_type_key_idx ON rankalpha.fact_score_history_2053 USING btree (score_type_key);

CREATE INDEX fact_score_history_2053_source_key_idx ON rankalpha.fact_score_history_2053 USING btree (source_key);

CREATE INDEX fact_score_history_2053_stock_key_idx ON rankalpha.fact_score_history_2053 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2054_pkey ON rankalpha.fact_score_history_2054 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2054_score_type_key_idx ON rankalpha.fact_score_history_2054 USING btree (score_type_key);

CREATE INDEX fact_score_history_2054_source_key_idx ON rankalpha.fact_score_history_2054 USING btree (source_key);

CREATE INDEX fact_score_history_2054_stock_key_idx ON rankalpha.fact_score_history_2054 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2055_pkey ON rankalpha.fact_score_history_2055 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2055_score_type_key_idx ON rankalpha.fact_score_history_2055 USING btree (score_type_key);

CREATE INDEX fact_score_history_2055_source_key_idx ON rankalpha.fact_score_history_2055 USING btree (source_key);

CREATE INDEX fact_score_history_2055_stock_key_idx ON rankalpha.fact_score_history_2055 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2056_pkey ON rankalpha.fact_score_history_2056 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2056_score_type_key_idx ON rankalpha.fact_score_history_2056 USING btree (score_type_key);

CREATE INDEX fact_score_history_2056_source_key_idx ON rankalpha.fact_score_history_2056 USING btree (source_key);

CREATE INDEX fact_score_history_2056_stock_key_idx ON rankalpha.fact_score_history_2056 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2057_pkey ON rankalpha.fact_score_history_2057 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2057_score_type_key_idx ON rankalpha.fact_score_history_2057 USING btree (score_type_key);

CREATE INDEX fact_score_history_2057_source_key_idx ON rankalpha.fact_score_history_2057 USING btree (source_key);

CREATE INDEX fact_score_history_2057_stock_key_idx ON rankalpha.fact_score_history_2057 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2058_pkey ON rankalpha.fact_score_history_2058 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2058_score_type_key_idx ON rankalpha.fact_score_history_2058 USING btree (score_type_key);

CREATE INDEX fact_score_history_2058_source_key_idx ON rankalpha.fact_score_history_2058 USING btree (source_key);

CREATE INDEX fact_score_history_2058_stock_key_idx ON rankalpha.fact_score_history_2058 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2059_pkey ON rankalpha.fact_score_history_2059 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2059_score_type_key_idx ON rankalpha.fact_score_history_2059 USING btree (score_type_key);

CREATE INDEX fact_score_history_2059_source_key_idx ON rankalpha.fact_score_history_2059 USING btree (source_key);

CREATE INDEX fact_score_history_2059_stock_key_idx ON rankalpha.fact_score_history_2059 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2060_pkey ON rankalpha.fact_score_history_2060 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2060_score_type_key_idx ON rankalpha.fact_score_history_2060 USING btree (score_type_key);

CREATE INDEX fact_score_history_2060_source_key_idx ON rankalpha.fact_score_history_2060 USING btree (source_key);

CREATE INDEX fact_score_history_2060_stock_key_idx ON rankalpha.fact_score_history_2060 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2061_pkey ON rankalpha.fact_score_history_2061 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2061_score_type_key_idx ON rankalpha.fact_score_history_2061 USING btree (score_type_key);

CREATE INDEX fact_score_history_2061_source_key_idx ON rankalpha.fact_score_history_2061 USING btree (source_key);

CREATE INDEX fact_score_history_2061_stock_key_idx ON rankalpha.fact_score_history_2061 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2062_pkey ON rankalpha.fact_score_history_2062 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2062_score_type_key_idx ON rankalpha.fact_score_history_2062 USING btree (score_type_key);

CREATE INDEX fact_score_history_2062_source_key_idx ON rankalpha.fact_score_history_2062 USING btree (source_key);

CREATE INDEX fact_score_history_2062_stock_key_idx ON rankalpha.fact_score_history_2062 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2063_pkey ON rankalpha.fact_score_history_2063 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2063_score_type_key_idx ON rankalpha.fact_score_history_2063 USING btree (score_type_key);

CREATE INDEX fact_score_history_2063_source_key_idx ON rankalpha.fact_score_history_2063 USING btree (source_key);

CREATE INDEX fact_score_history_2063_stock_key_idx ON rankalpha.fact_score_history_2063 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2064_pkey ON rankalpha.fact_score_history_2064 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2064_score_type_key_idx ON rankalpha.fact_score_history_2064 USING btree (score_type_key);

CREATE INDEX fact_score_history_2064_source_key_idx ON rankalpha.fact_score_history_2064 USING btree (source_key);

CREATE INDEX fact_score_history_2064_stock_key_idx ON rankalpha.fact_score_history_2064 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2065_pkey ON rankalpha.fact_score_history_2065 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2065_score_type_key_idx ON rankalpha.fact_score_history_2065 USING btree (score_type_key);

CREATE INDEX fact_score_history_2065_source_key_idx ON rankalpha.fact_score_history_2065 USING btree (source_key);

CREATE INDEX fact_score_history_2065_stock_key_idx ON rankalpha.fact_score_history_2065 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2066_pkey ON rankalpha.fact_score_history_2066 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2066_score_type_key_idx ON rankalpha.fact_score_history_2066 USING btree (score_type_key);

CREATE INDEX fact_score_history_2066_source_key_idx ON rankalpha.fact_score_history_2066 USING btree (source_key);

CREATE INDEX fact_score_history_2066_stock_key_idx ON rankalpha.fact_score_history_2066 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2067_pkey ON rankalpha.fact_score_history_2067 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2067_score_type_key_idx ON rankalpha.fact_score_history_2067 USING btree (score_type_key);

CREATE INDEX fact_score_history_2067_source_key_idx ON rankalpha.fact_score_history_2067 USING btree (source_key);

CREATE INDEX fact_score_history_2067_stock_key_idx ON rankalpha.fact_score_history_2067 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2068_pkey ON rankalpha.fact_score_history_2068 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2068_score_type_key_idx ON rankalpha.fact_score_history_2068 USING btree (score_type_key);

CREATE INDEX fact_score_history_2068_source_key_idx ON rankalpha.fact_score_history_2068 USING btree (source_key);

CREATE INDEX fact_score_history_2068_stock_key_idx ON rankalpha.fact_score_history_2068 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2069_pkey ON rankalpha.fact_score_history_2069 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2069_score_type_key_idx ON rankalpha.fact_score_history_2069 USING btree (score_type_key);

CREATE INDEX fact_score_history_2069_source_key_idx ON rankalpha.fact_score_history_2069 USING btree (source_key);

CREATE INDEX fact_score_history_2069_stock_key_idx ON rankalpha.fact_score_history_2069 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2070_pkey ON rankalpha.fact_score_history_2070 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2070_score_type_key_idx ON rankalpha.fact_score_history_2070 USING btree (score_type_key);

CREATE INDEX fact_score_history_2070_source_key_idx ON rankalpha.fact_score_history_2070 USING btree (source_key);

CREATE INDEX fact_score_history_2070_stock_key_idx ON rankalpha.fact_score_history_2070 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2071_pkey ON rankalpha.fact_score_history_2071 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2071_score_type_key_idx ON rankalpha.fact_score_history_2071 USING btree (score_type_key);

CREATE INDEX fact_score_history_2071_source_key_idx ON rankalpha.fact_score_history_2071 USING btree (source_key);

CREATE INDEX fact_score_history_2071_stock_key_idx ON rankalpha.fact_score_history_2071 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2072_pkey ON rankalpha.fact_score_history_2072 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2072_score_type_key_idx ON rankalpha.fact_score_history_2072 USING btree (score_type_key);

CREATE INDEX fact_score_history_2072_source_key_idx ON rankalpha.fact_score_history_2072 USING btree (source_key);

CREATE INDEX fact_score_history_2072_stock_key_idx ON rankalpha.fact_score_history_2072 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2073_pkey ON rankalpha.fact_score_history_2073 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2073_score_type_key_idx ON rankalpha.fact_score_history_2073 USING btree (score_type_key);

CREATE INDEX fact_score_history_2073_source_key_idx ON rankalpha.fact_score_history_2073 USING btree (source_key);

CREATE INDEX fact_score_history_2073_stock_key_idx ON rankalpha.fact_score_history_2073 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2074_pkey ON rankalpha.fact_score_history_2074 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2074_score_type_key_idx ON rankalpha.fact_score_history_2074 USING btree (score_type_key);

CREATE INDEX fact_score_history_2074_source_key_idx ON rankalpha.fact_score_history_2074 USING btree (source_key);

CREATE INDEX fact_score_history_2074_stock_key_idx ON rankalpha.fact_score_history_2074 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2075_pkey ON rankalpha.fact_score_history_2075 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2075_score_type_key_idx ON rankalpha.fact_score_history_2075 USING btree (score_type_key);

CREATE INDEX fact_score_history_2075_source_key_idx ON rankalpha.fact_score_history_2075 USING btree (source_key);

CREATE INDEX fact_score_history_2075_stock_key_idx ON rankalpha.fact_score_history_2075 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2076_pkey ON rankalpha.fact_score_history_2076 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2076_score_type_key_idx ON rankalpha.fact_score_history_2076 USING btree (score_type_key);

CREATE INDEX fact_score_history_2076_source_key_idx ON rankalpha.fact_score_history_2076 USING btree (source_key);

CREATE INDEX fact_score_history_2076_stock_key_idx ON rankalpha.fact_score_history_2076 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2077_pkey ON rankalpha.fact_score_history_2077 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2077_score_type_key_idx ON rankalpha.fact_score_history_2077 USING btree (score_type_key);

CREATE INDEX fact_score_history_2077_source_key_idx ON rankalpha.fact_score_history_2077 USING btree (source_key);

CREATE INDEX fact_score_history_2077_stock_key_idx ON rankalpha.fact_score_history_2077 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2078_pkey ON rankalpha.fact_score_history_2078 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2078_score_type_key_idx ON rankalpha.fact_score_history_2078 USING btree (score_type_key);

CREATE INDEX fact_score_history_2078_source_key_idx ON rankalpha.fact_score_history_2078 USING btree (source_key);

CREATE INDEX fact_score_history_2078_stock_key_idx ON rankalpha.fact_score_history_2078 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2079_pkey ON rankalpha.fact_score_history_2079 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2079_score_type_key_idx ON rankalpha.fact_score_history_2079 USING btree (score_type_key);

CREATE INDEX fact_score_history_2079_source_key_idx ON rankalpha.fact_score_history_2079 USING btree (source_key);

CREATE INDEX fact_score_history_2079_stock_key_idx ON rankalpha.fact_score_history_2079 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2080_pkey ON rankalpha.fact_score_history_2080 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2080_score_type_key_idx ON rankalpha.fact_score_history_2080 USING btree (score_type_key);

CREATE INDEX fact_score_history_2080_source_key_idx ON rankalpha.fact_score_history_2080 USING btree (source_key);

CREATE INDEX fact_score_history_2080_stock_key_idx ON rankalpha.fact_score_history_2080 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2081_pkey ON rankalpha.fact_score_history_2081 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2081_score_type_key_idx ON rankalpha.fact_score_history_2081 USING btree (score_type_key);

CREATE INDEX fact_score_history_2081_source_key_idx ON rankalpha.fact_score_history_2081 USING btree (source_key);

CREATE INDEX fact_score_history_2081_stock_key_idx ON rankalpha.fact_score_history_2081 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2082_pkey ON rankalpha.fact_score_history_2082 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2082_score_type_key_idx ON rankalpha.fact_score_history_2082 USING btree (score_type_key);

CREATE INDEX fact_score_history_2082_source_key_idx ON rankalpha.fact_score_history_2082 USING btree (source_key);

CREATE INDEX fact_score_history_2082_stock_key_idx ON rankalpha.fact_score_history_2082 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2083_pkey ON rankalpha.fact_score_history_2083 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2083_score_type_key_idx ON rankalpha.fact_score_history_2083 USING btree (score_type_key);

CREATE INDEX fact_score_history_2083_source_key_idx ON rankalpha.fact_score_history_2083 USING btree (source_key);

CREATE INDEX fact_score_history_2083_stock_key_idx ON rankalpha.fact_score_history_2083 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2084_pkey ON rankalpha.fact_score_history_2084 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2084_score_type_key_idx ON rankalpha.fact_score_history_2084 USING btree (score_type_key);

CREATE INDEX fact_score_history_2084_source_key_idx ON rankalpha.fact_score_history_2084 USING btree (source_key);

CREATE INDEX fact_score_history_2084_stock_key_idx ON rankalpha.fact_score_history_2084 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2085_pkey ON rankalpha.fact_score_history_2085 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2085_score_type_key_idx ON rankalpha.fact_score_history_2085 USING btree (score_type_key);

CREATE INDEX fact_score_history_2085_source_key_idx ON rankalpha.fact_score_history_2085 USING btree (source_key);

CREATE INDEX fact_score_history_2085_stock_key_idx ON rankalpha.fact_score_history_2085 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2086_pkey ON rankalpha.fact_score_history_2086 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2086_score_type_key_idx ON rankalpha.fact_score_history_2086 USING btree (score_type_key);

CREATE INDEX fact_score_history_2086_source_key_idx ON rankalpha.fact_score_history_2086 USING btree (source_key);

CREATE INDEX fact_score_history_2086_stock_key_idx ON rankalpha.fact_score_history_2086 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2087_pkey ON rankalpha.fact_score_history_2087 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2087_score_type_key_idx ON rankalpha.fact_score_history_2087 USING btree (score_type_key);

CREATE INDEX fact_score_history_2087_source_key_idx ON rankalpha.fact_score_history_2087 USING btree (source_key);

CREATE INDEX fact_score_history_2087_stock_key_idx ON rankalpha.fact_score_history_2087 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2088_pkey ON rankalpha.fact_score_history_2088 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2088_score_type_key_idx ON rankalpha.fact_score_history_2088 USING btree (score_type_key);

CREATE INDEX fact_score_history_2088_source_key_idx ON rankalpha.fact_score_history_2088 USING btree (source_key);

CREATE INDEX fact_score_history_2088_stock_key_idx ON rankalpha.fact_score_history_2088 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2089_pkey ON rankalpha.fact_score_history_2089 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2089_score_type_key_idx ON rankalpha.fact_score_history_2089 USING btree (score_type_key);

CREATE INDEX fact_score_history_2089_source_key_idx ON rankalpha.fact_score_history_2089 USING btree (source_key);

CREATE INDEX fact_score_history_2089_stock_key_idx ON rankalpha.fact_score_history_2089 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2090_pkey ON rankalpha.fact_score_history_2090 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2090_score_type_key_idx ON rankalpha.fact_score_history_2090 USING btree (score_type_key);

CREATE INDEX fact_score_history_2090_source_key_idx ON rankalpha.fact_score_history_2090 USING btree (source_key);

CREATE INDEX fact_score_history_2090_stock_key_idx ON rankalpha.fact_score_history_2090 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2091_pkey ON rankalpha.fact_score_history_2091 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2091_score_type_key_idx ON rankalpha.fact_score_history_2091 USING btree (score_type_key);

CREATE INDEX fact_score_history_2091_source_key_idx ON rankalpha.fact_score_history_2091 USING btree (source_key);

CREATE INDEX fact_score_history_2091_stock_key_idx ON rankalpha.fact_score_history_2091 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2092_pkey ON rankalpha.fact_score_history_2092 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2092_score_type_key_idx ON rankalpha.fact_score_history_2092 USING btree (score_type_key);

CREATE INDEX fact_score_history_2092_source_key_idx ON rankalpha.fact_score_history_2092 USING btree (source_key);

CREATE INDEX fact_score_history_2092_stock_key_idx ON rankalpha.fact_score_history_2092 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2093_pkey ON rankalpha.fact_score_history_2093 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2093_score_type_key_idx ON rankalpha.fact_score_history_2093 USING btree (score_type_key);

CREATE INDEX fact_score_history_2093_source_key_idx ON rankalpha.fact_score_history_2093 USING btree (source_key);

CREATE INDEX fact_score_history_2093_stock_key_idx ON rankalpha.fact_score_history_2093 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2094_pkey ON rankalpha.fact_score_history_2094 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2094_score_type_key_idx ON rankalpha.fact_score_history_2094 USING btree (score_type_key);

CREATE INDEX fact_score_history_2094_source_key_idx ON rankalpha.fact_score_history_2094 USING btree (source_key);

CREATE INDEX fact_score_history_2094_stock_key_idx ON rankalpha.fact_score_history_2094 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2095_pkey ON rankalpha.fact_score_history_2095 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2095_score_type_key_idx ON rankalpha.fact_score_history_2095 USING btree (score_type_key);

CREATE INDEX fact_score_history_2095_source_key_idx ON rankalpha.fact_score_history_2095 USING btree (source_key);

CREATE INDEX fact_score_history_2095_stock_key_idx ON rankalpha.fact_score_history_2095 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2096_pkey ON rankalpha.fact_score_history_2096 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2096_score_type_key_idx ON rankalpha.fact_score_history_2096 USING btree (score_type_key);

CREATE INDEX fact_score_history_2096_source_key_idx ON rankalpha.fact_score_history_2096 USING btree (source_key);

CREATE INDEX fact_score_history_2096_stock_key_idx ON rankalpha.fact_score_history_2096 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2097_pkey ON rankalpha.fact_score_history_2097 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2097_score_type_key_idx ON rankalpha.fact_score_history_2097 USING btree (score_type_key);

CREATE INDEX fact_score_history_2097_source_key_idx ON rankalpha.fact_score_history_2097 USING btree (source_key);

CREATE INDEX fact_score_history_2097_stock_key_idx ON rankalpha.fact_score_history_2097 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2098_pkey ON rankalpha.fact_score_history_2098 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2098_score_type_key_idx ON rankalpha.fact_score_history_2098 USING btree (score_type_key);

CREATE INDEX fact_score_history_2098_source_key_idx ON rankalpha.fact_score_history_2098 USING btree (source_key);

CREATE INDEX fact_score_history_2098_stock_key_idx ON rankalpha.fact_score_history_2098 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2099_pkey ON rankalpha.fact_score_history_2099 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2099_score_type_key_idx ON rankalpha.fact_score_history_2099 USING btree (score_type_key);

CREATE INDEX fact_score_history_2099_source_key_idx ON rankalpha.fact_score_history_2099 USING btree (source_key);

CREATE INDEX fact_score_history_2099_stock_key_idx ON rankalpha.fact_score_history_2099 USING btree (stock_key);

CREATE UNIQUE INDEX fact_score_history_2100_pkey ON rankalpha.fact_score_history_2100 USING btree (date_key, fact_id);

CREATE INDEX fact_score_history_2100_score_type_key_idx ON rankalpha.fact_score_history_2100 USING btree (score_type_key);

CREATE INDEX fact_score_history_2100_source_key_idx ON rankalpha.fact_score_history_2100 USING btree (source_key);

CREATE INDEX fact_score_history_2100_stock_key_idx ON rankalpha.fact_score_history_2100 USING btree (stock_key);

CREATE UNIQUE INDEX fact_screener_rank_pkey ON ONLY rankalpha.fact_screener_rank USING btree (date_key, fact_id);

CREATE INDEX ix_fact_rank_date ON ONLY rankalpha.fact_screener_rank USING btree (date_key);

CREATE INDEX ix_fact_rank_sk_ssk_dk ON ONLY rankalpha.fact_screener_rank USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX ix_fact_rank_snapshot ON ONLY rankalpha.fact_screener_rank USING btree (screening_runid);

CREATE INDEX ix_fact_rank_source ON ONLY rankalpha.fact_screener_rank USING btree (source_key);

CREATE INDEX ix_fact_rank_stock ON ONLY rankalpha.fact_screener_rank USING btree (stock_key);

CREATE INDEX ix_fact_rank_style ON ONLY rankalpha.fact_screener_rank USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_01_date_key_idx ON rankalpha.fact_screener_rank_2015_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_01_pkey ON rankalpha.fact_screener_rank_2015_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_01_screening_runid_idx ON rankalpha.fact_screener_rank_2015_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_01_source_key_idx ON rankalpha.fact_screener_rank_2015_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_01_stock_key_idx ON rankalpha.fact_screener_rank_2015_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_01_style_key_idx ON rankalpha.fact_screener_rank_2015_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_02_date_key_idx ON rankalpha.fact_screener_rank_2015_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_02_pkey ON rankalpha.fact_screener_rank_2015_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_02_screening_runid_idx ON rankalpha.fact_screener_rank_2015_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_02_source_key_idx ON rankalpha.fact_screener_rank_2015_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_02_stock_key_idx ON rankalpha.fact_screener_rank_2015_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_02_style_key_idx ON rankalpha.fact_screener_rank_2015_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_03_date_key_idx ON rankalpha.fact_screener_rank_2015_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_03_pkey ON rankalpha.fact_screener_rank_2015_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_03_screening_runid_idx ON rankalpha.fact_screener_rank_2015_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_03_source_key_idx ON rankalpha.fact_screener_rank_2015_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_03_stock_key_idx ON rankalpha.fact_screener_rank_2015_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_03_style_key_idx ON rankalpha.fact_screener_rank_2015_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_04_date_key_idx ON rankalpha.fact_screener_rank_2015_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_04_pkey ON rankalpha.fact_screener_rank_2015_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_04_screening_runid_idx ON rankalpha.fact_screener_rank_2015_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_04_source_key_idx ON rankalpha.fact_screener_rank_2015_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_04_stock_key_idx ON rankalpha.fact_screener_rank_2015_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_04_style_key_idx ON rankalpha.fact_screener_rank_2015_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_05_date_key_idx ON rankalpha.fact_screener_rank_2015_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_05_pkey ON rankalpha.fact_screener_rank_2015_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_05_screening_runid_idx ON rankalpha.fact_screener_rank_2015_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_05_source_key_idx ON rankalpha.fact_screener_rank_2015_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_05_stock_key_idx ON rankalpha.fact_screener_rank_2015_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_05_style_key_idx ON rankalpha.fact_screener_rank_2015_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_06_date_key_idx ON rankalpha.fact_screener_rank_2015_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_06_pkey ON rankalpha.fact_screener_rank_2015_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_06_screening_runid_idx ON rankalpha.fact_screener_rank_2015_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_06_source_key_idx ON rankalpha.fact_screener_rank_2015_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_06_stock_key_idx ON rankalpha.fact_screener_rank_2015_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_06_style_key_idx ON rankalpha.fact_screener_rank_2015_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_07_date_key_idx ON rankalpha.fact_screener_rank_2015_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_07_pkey ON rankalpha.fact_screener_rank_2015_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_07_screening_runid_idx ON rankalpha.fact_screener_rank_2015_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_07_source_key_idx ON rankalpha.fact_screener_rank_2015_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_07_stock_key_idx ON rankalpha.fact_screener_rank_2015_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_07_style_key_idx ON rankalpha.fact_screener_rank_2015_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_08_date_key_idx ON rankalpha.fact_screener_rank_2015_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_08_pkey ON rankalpha.fact_screener_rank_2015_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_08_screening_runid_idx ON rankalpha.fact_screener_rank_2015_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_08_source_key_idx ON rankalpha.fact_screener_rank_2015_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_08_stock_key_idx ON rankalpha.fact_screener_rank_2015_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_08_style_key_idx ON rankalpha.fact_screener_rank_2015_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_09_date_key_idx ON rankalpha.fact_screener_rank_2015_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_09_pkey ON rankalpha.fact_screener_rank_2015_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_09_screening_runid_idx ON rankalpha.fact_screener_rank_2015_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_09_source_key_idx ON rankalpha.fact_screener_rank_2015_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_09_stock_key_idx ON rankalpha.fact_screener_rank_2015_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_09_style_key_idx ON rankalpha.fact_screener_rank_2015_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_10_date_key_idx ON rankalpha.fact_screener_rank_2015_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_10_pkey ON rankalpha.fact_screener_rank_2015_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_10_screening_runid_idx ON rankalpha.fact_screener_rank_2015_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_10_source_key_idx ON rankalpha.fact_screener_rank_2015_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_10_stock_key_idx ON rankalpha.fact_screener_rank_2015_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_10_style_key_idx ON rankalpha.fact_screener_rank_2015_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_11_date_key_idx ON rankalpha.fact_screener_rank_2015_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_11_pkey ON rankalpha.fact_screener_rank_2015_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_11_screening_runid_idx ON rankalpha.fact_screener_rank_2015_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_11_source_key_idx ON rankalpha.fact_screener_rank_2015_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_11_stock_key_idx ON rankalpha.fact_screener_rank_2015_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_11_style_key_idx ON rankalpha.fact_screener_rank_2015_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2015_12_date_key_idx ON rankalpha.fact_screener_rank_2015_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2015_12_pkey ON rankalpha.fact_screener_rank_2015_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2015_12_screening_runid_idx ON rankalpha.fact_screener_rank_2015_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2015_12_source_key_idx ON rankalpha.fact_screener_rank_2015_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2015_12_stock_key_idx ON rankalpha.fact_screener_rank_2015_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2015_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2015_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2015_12_style_key_idx ON rankalpha.fact_screener_rank_2015_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_01_date_key_idx ON rankalpha.fact_screener_rank_2016_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_01_pkey ON rankalpha.fact_screener_rank_2016_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_01_screening_runid_idx ON rankalpha.fact_screener_rank_2016_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_01_source_key_idx ON rankalpha.fact_screener_rank_2016_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_01_stock_key_idx ON rankalpha.fact_screener_rank_2016_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_01_style_key_idx ON rankalpha.fact_screener_rank_2016_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_02_date_key_idx ON rankalpha.fact_screener_rank_2016_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_02_pkey ON rankalpha.fact_screener_rank_2016_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_02_screening_runid_idx ON rankalpha.fact_screener_rank_2016_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_02_source_key_idx ON rankalpha.fact_screener_rank_2016_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_02_stock_key_idx ON rankalpha.fact_screener_rank_2016_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_02_style_key_idx ON rankalpha.fact_screener_rank_2016_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_03_date_key_idx ON rankalpha.fact_screener_rank_2016_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_03_pkey ON rankalpha.fact_screener_rank_2016_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_03_screening_runid_idx ON rankalpha.fact_screener_rank_2016_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_03_source_key_idx ON rankalpha.fact_screener_rank_2016_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_03_stock_key_idx ON rankalpha.fact_screener_rank_2016_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_03_style_key_idx ON rankalpha.fact_screener_rank_2016_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_04_date_key_idx ON rankalpha.fact_screener_rank_2016_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_04_pkey ON rankalpha.fact_screener_rank_2016_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_04_screening_runid_idx ON rankalpha.fact_screener_rank_2016_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_04_source_key_idx ON rankalpha.fact_screener_rank_2016_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_04_stock_key_idx ON rankalpha.fact_screener_rank_2016_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_04_style_key_idx ON rankalpha.fact_screener_rank_2016_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_05_date_key_idx ON rankalpha.fact_screener_rank_2016_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_05_pkey ON rankalpha.fact_screener_rank_2016_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_05_screening_runid_idx ON rankalpha.fact_screener_rank_2016_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_05_source_key_idx ON rankalpha.fact_screener_rank_2016_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_05_stock_key_idx ON rankalpha.fact_screener_rank_2016_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_05_style_key_idx ON rankalpha.fact_screener_rank_2016_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_06_date_key_idx ON rankalpha.fact_screener_rank_2016_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_06_pkey ON rankalpha.fact_screener_rank_2016_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_06_screening_runid_idx ON rankalpha.fact_screener_rank_2016_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_06_source_key_idx ON rankalpha.fact_screener_rank_2016_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_06_stock_key_idx ON rankalpha.fact_screener_rank_2016_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_06_style_key_idx ON rankalpha.fact_screener_rank_2016_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_07_date_key_idx ON rankalpha.fact_screener_rank_2016_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_07_pkey ON rankalpha.fact_screener_rank_2016_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_07_screening_runid_idx ON rankalpha.fact_screener_rank_2016_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_07_source_key_idx ON rankalpha.fact_screener_rank_2016_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_07_stock_key_idx ON rankalpha.fact_screener_rank_2016_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_07_style_key_idx ON rankalpha.fact_screener_rank_2016_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_08_date_key_idx ON rankalpha.fact_screener_rank_2016_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_08_pkey ON rankalpha.fact_screener_rank_2016_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_08_screening_runid_idx ON rankalpha.fact_screener_rank_2016_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_08_source_key_idx ON rankalpha.fact_screener_rank_2016_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_08_stock_key_idx ON rankalpha.fact_screener_rank_2016_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_08_style_key_idx ON rankalpha.fact_screener_rank_2016_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_09_date_key_idx ON rankalpha.fact_screener_rank_2016_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_09_pkey ON rankalpha.fact_screener_rank_2016_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_09_screening_runid_idx ON rankalpha.fact_screener_rank_2016_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_09_source_key_idx ON rankalpha.fact_screener_rank_2016_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_09_stock_key_idx ON rankalpha.fact_screener_rank_2016_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_09_style_key_idx ON rankalpha.fact_screener_rank_2016_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_10_date_key_idx ON rankalpha.fact_screener_rank_2016_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_10_pkey ON rankalpha.fact_screener_rank_2016_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_10_screening_runid_idx ON rankalpha.fact_screener_rank_2016_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_10_source_key_idx ON rankalpha.fact_screener_rank_2016_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_10_stock_key_idx ON rankalpha.fact_screener_rank_2016_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_10_style_key_idx ON rankalpha.fact_screener_rank_2016_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_11_date_key_idx ON rankalpha.fact_screener_rank_2016_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_11_pkey ON rankalpha.fact_screener_rank_2016_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_11_screening_runid_idx ON rankalpha.fact_screener_rank_2016_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_11_source_key_idx ON rankalpha.fact_screener_rank_2016_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_11_stock_key_idx ON rankalpha.fact_screener_rank_2016_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_11_style_key_idx ON rankalpha.fact_screener_rank_2016_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2016_12_date_key_idx ON rankalpha.fact_screener_rank_2016_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2016_12_pkey ON rankalpha.fact_screener_rank_2016_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2016_12_screening_runid_idx ON rankalpha.fact_screener_rank_2016_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2016_12_source_key_idx ON rankalpha.fact_screener_rank_2016_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2016_12_stock_key_idx ON rankalpha.fact_screener_rank_2016_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2016_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2016_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2016_12_style_key_idx ON rankalpha.fact_screener_rank_2016_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_01_date_key_idx ON rankalpha.fact_screener_rank_2017_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_01_pkey ON rankalpha.fact_screener_rank_2017_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_01_screening_runid_idx ON rankalpha.fact_screener_rank_2017_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_01_source_key_idx ON rankalpha.fact_screener_rank_2017_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_01_stock_key_idx ON rankalpha.fact_screener_rank_2017_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_01_style_key_idx ON rankalpha.fact_screener_rank_2017_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_02_date_key_idx ON rankalpha.fact_screener_rank_2017_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_02_pkey ON rankalpha.fact_screener_rank_2017_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_02_screening_runid_idx ON rankalpha.fact_screener_rank_2017_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_02_source_key_idx ON rankalpha.fact_screener_rank_2017_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_02_stock_key_idx ON rankalpha.fact_screener_rank_2017_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_02_style_key_idx ON rankalpha.fact_screener_rank_2017_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_03_date_key_idx ON rankalpha.fact_screener_rank_2017_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_03_pkey ON rankalpha.fact_screener_rank_2017_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_03_screening_runid_idx ON rankalpha.fact_screener_rank_2017_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_03_source_key_idx ON rankalpha.fact_screener_rank_2017_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_03_stock_key_idx ON rankalpha.fact_screener_rank_2017_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_03_style_key_idx ON rankalpha.fact_screener_rank_2017_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_04_date_key_idx ON rankalpha.fact_screener_rank_2017_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_04_pkey ON rankalpha.fact_screener_rank_2017_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_04_screening_runid_idx ON rankalpha.fact_screener_rank_2017_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_04_source_key_idx ON rankalpha.fact_screener_rank_2017_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_04_stock_key_idx ON rankalpha.fact_screener_rank_2017_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_04_style_key_idx ON rankalpha.fact_screener_rank_2017_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_05_date_key_idx ON rankalpha.fact_screener_rank_2017_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_05_pkey ON rankalpha.fact_screener_rank_2017_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_05_screening_runid_idx ON rankalpha.fact_screener_rank_2017_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_05_source_key_idx ON rankalpha.fact_screener_rank_2017_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_05_stock_key_idx ON rankalpha.fact_screener_rank_2017_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_05_style_key_idx ON rankalpha.fact_screener_rank_2017_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_06_date_key_idx ON rankalpha.fact_screener_rank_2017_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_06_pkey ON rankalpha.fact_screener_rank_2017_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_06_screening_runid_idx ON rankalpha.fact_screener_rank_2017_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_06_source_key_idx ON rankalpha.fact_screener_rank_2017_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_06_stock_key_idx ON rankalpha.fact_screener_rank_2017_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_06_style_key_idx ON rankalpha.fact_screener_rank_2017_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_07_date_key_idx ON rankalpha.fact_screener_rank_2017_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_07_pkey ON rankalpha.fact_screener_rank_2017_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_07_screening_runid_idx ON rankalpha.fact_screener_rank_2017_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_07_source_key_idx ON rankalpha.fact_screener_rank_2017_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_07_stock_key_idx ON rankalpha.fact_screener_rank_2017_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_07_style_key_idx ON rankalpha.fact_screener_rank_2017_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_08_date_key_idx ON rankalpha.fact_screener_rank_2017_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_08_pkey ON rankalpha.fact_screener_rank_2017_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_08_screening_runid_idx ON rankalpha.fact_screener_rank_2017_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_08_source_key_idx ON rankalpha.fact_screener_rank_2017_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_08_stock_key_idx ON rankalpha.fact_screener_rank_2017_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_08_style_key_idx ON rankalpha.fact_screener_rank_2017_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_09_date_key_idx ON rankalpha.fact_screener_rank_2017_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_09_pkey ON rankalpha.fact_screener_rank_2017_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_09_screening_runid_idx ON rankalpha.fact_screener_rank_2017_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_09_source_key_idx ON rankalpha.fact_screener_rank_2017_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_09_stock_key_idx ON rankalpha.fact_screener_rank_2017_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_09_style_key_idx ON rankalpha.fact_screener_rank_2017_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_10_date_key_idx ON rankalpha.fact_screener_rank_2017_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_10_pkey ON rankalpha.fact_screener_rank_2017_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_10_screening_runid_idx ON rankalpha.fact_screener_rank_2017_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_10_source_key_idx ON rankalpha.fact_screener_rank_2017_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_10_stock_key_idx ON rankalpha.fact_screener_rank_2017_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_10_style_key_idx ON rankalpha.fact_screener_rank_2017_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_11_date_key_idx ON rankalpha.fact_screener_rank_2017_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_11_pkey ON rankalpha.fact_screener_rank_2017_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_11_screening_runid_idx ON rankalpha.fact_screener_rank_2017_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_11_source_key_idx ON rankalpha.fact_screener_rank_2017_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_11_stock_key_idx ON rankalpha.fact_screener_rank_2017_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_11_style_key_idx ON rankalpha.fact_screener_rank_2017_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2017_12_date_key_idx ON rankalpha.fact_screener_rank_2017_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2017_12_pkey ON rankalpha.fact_screener_rank_2017_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2017_12_screening_runid_idx ON rankalpha.fact_screener_rank_2017_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2017_12_source_key_idx ON rankalpha.fact_screener_rank_2017_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2017_12_stock_key_idx ON rankalpha.fact_screener_rank_2017_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2017_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2017_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2017_12_style_key_idx ON rankalpha.fact_screener_rank_2017_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_01_date_key_idx ON rankalpha.fact_screener_rank_2018_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_01_pkey ON rankalpha.fact_screener_rank_2018_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_01_screening_runid_idx ON rankalpha.fact_screener_rank_2018_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_01_source_key_idx ON rankalpha.fact_screener_rank_2018_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_01_stock_key_idx ON rankalpha.fact_screener_rank_2018_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_01_style_key_idx ON rankalpha.fact_screener_rank_2018_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_02_date_key_idx ON rankalpha.fact_screener_rank_2018_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_02_pkey ON rankalpha.fact_screener_rank_2018_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_02_screening_runid_idx ON rankalpha.fact_screener_rank_2018_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_02_source_key_idx ON rankalpha.fact_screener_rank_2018_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_02_stock_key_idx ON rankalpha.fact_screener_rank_2018_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_02_style_key_idx ON rankalpha.fact_screener_rank_2018_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_03_date_key_idx ON rankalpha.fact_screener_rank_2018_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_03_pkey ON rankalpha.fact_screener_rank_2018_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_03_screening_runid_idx ON rankalpha.fact_screener_rank_2018_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_03_source_key_idx ON rankalpha.fact_screener_rank_2018_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_03_stock_key_idx ON rankalpha.fact_screener_rank_2018_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_03_style_key_idx ON rankalpha.fact_screener_rank_2018_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_04_date_key_idx ON rankalpha.fact_screener_rank_2018_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_04_pkey ON rankalpha.fact_screener_rank_2018_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_04_screening_runid_idx ON rankalpha.fact_screener_rank_2018_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_04_source_key_idx ON rankalpha.fact_screener_rank_2018_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_04_stock_key_idx ON rankalpha.fact_screener_rank_2018_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_04_style_key_idx ON rankalpha.fact_screener_rank_2018_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_05_date_key_idx ON rankalpha.fact_screener_rank_2018_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_05_pkey ON rankalpha.fact_screener_rank_2018_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_05_screening_runid_idx ON rankalpha.fact_screener_rank_2018_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_05_source_key_idx ON rankalpha.fact_screener_rank_2018_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_05_stock_key_idx ON rankalpha.fact_screener_rank_2018_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_05_style_key_idx ON rankalpha.fact_screener_rank_2018_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_06_date_key_idx ON rankalpha.fact_screener_rank_2018_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_06_pkey ON rankalpha.fact_screener_rank_2018_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_06_screening_runid_idx ON rankalpha.fact_screener_rank_2018_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_06_source_key_idx ON rankalpha.fact_screener_rank_2018_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_06_stock_key_idx ON rankalpha.fact_screener_rank_2018_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_06_style_key_idx ON rankalpha.fact_screener_rank_2018_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_07_date_key_idx ON rankalpha.fact_screener_rank_2018_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_07_pkey ON rankalpha.fact_screener_rank_2018_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_07_screening_runid_idx ON rankalpha.fact_screener_rank_2018_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_07_source_key_idx ON rankalpha.fact_screener_rank_2018_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_07_stock_key_idx ON rankalpha.fact_screener_rank_2018_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_07_style_key_idx ON rankalpha.fact_screener_rank_2018_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_08_date_key_idx ON rankalpha.fact_screener_rank_2018_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_08_pkey ON rankalpha.fact_screener_rank_2018_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_08_screening_runid_idx ON rankalpha.fact_screener_rank_2018_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_08_source_key_idx ON rankalpha.fact_screener_rank_2018_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_08_stock_key_idx ON rankalpha.fact_screener_rank_2018_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_08_style_key_idx ON rankalpha.fact_screener_rank_2018_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_09_date_key_idx ON rankalpha.fact_screener_rank_2018_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_09_pkey ON rankalpha.fact_screener_rank_2018_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_09_screening_runid_idx ON rankalpha.fact_screener_rank_2018_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_09_source_key_idx ON rankalpha.fact_screener_rank_2018_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_09_stock_key_idx ON rankalpha.fact_screener_rank_2018_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_09_style_key_idx ON rankalpha.fact_screener_rank_2018_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_10_date_key_idx ON rankalpha.fact_screener_rank_2018_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_10_pkey ON rankalpha.fact_screener_rank_2018_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_10_screening_runid_idx ON rankalpha.fact_screener_rank_2018_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_10_source_key_idx ON rankalpha.fact_screener_rank_2018_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_10_stock_key_idx ON rankalpha.fact_screener_rank_2018_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_10_style_key_idx ON rankalpha.fact_screener_rank_2018_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_11_date_key_idx ON rankalpha.fact_screener_rank_2018_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_11_pkey ON rankalpha.fact_screener_rank_2018_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_11_screening_runid_idx ON rankalpha.fact_screener_rank_2018_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_11_source_key_idx ON rankalpha.fact_screener_rank_2018_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_11_stock_key_idx ON rankalpha.fact_screener_rank_2018_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_11_style_key_idx ON rankalpha.fact_screener_rank_2018_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2018_12_date_key_idx ON rankalpha.fact_screener_rank_2018_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2018_12_pkey ON rankalpha.fact_screener_rank_2018_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2018_12_screening_runid_idx ON rankalpha.fact_screener_rank_2018_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2018_12_source_key_idx ON rankalpha.fact_screener_rank_2018_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2018_12_stock_key_idx ON rankalpha.fact_screener_rank_2018_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2018_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2018_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2018_12_style_key_idx ON rankalpha.fact_screener_rank_2018_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_01_date_key_idx ON rankalpha.fact_screener_rank_2019_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_01_pkey ON rankalpha.fact_screener_rank_2019_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_01_screening_runid_idx ON rankalpha.fact_screener_rank_2019_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_01_source_key_idx ON rankalpha.fact_screener_rank_2019_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_01_stock_key_idx ON rankalpha.fact_screener_rank_2019_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_01_style_key_idx ON rankalpha.fact_screener_rank_2019_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_02_date_key_idx ON rankalpha.fact_screener_rank_2019_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_02_pkey ON rankalpha.fact_screener_rank_2019_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_02_screening_runid_idx ON rankalpha.fact_screener_rank_2019_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_02_source_key_idx ON rankalpha.fact_screener_rank_2019_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_02_stock_key_idx ON rankalpha.fact_screener_rank_2019_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_02_style_key_idx ON rankalpha.fact_screener_rank_2019_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_03_date_key_idx ON rankalpha.fact_screener_rank_2019_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_03_pkey ON rankalpha.fact_screener_rank_2019_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_03_screening_runid_idx ON rankalpha.fact_screener_rank_2019_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_03_source_key_idx ON rankalpha.fact_screener_rank_2019_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_03_stock_key_idx ON rankalpha.fact_screener_rank_2019_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_03_style_key_idx ON rankalpha.fact_screener_rank_2019_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_04_date_key_idx ON rankalpha.fact_screener_rank_2019_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_04_pkey ON rankalpha.fact_screener_rank_2019_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_04_screening_runid_idx ON rankalpha.fact_screener_rank_2019_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_04_source_key_idx ON rankalpha.fact_screener_rank_2019_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_04_stock_key_idx ON rankalpha.fact_screener_rank_2019_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_04_style_key_idx ON rankalpha.fact_screener_rank_2019_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_05_date_key_idx ON rankalpha.fact_screener_rank_2019_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_05_pkey ON rankalpha.fact_screener_rank_2019_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_05_screening_runid_idx ON rankalpha.fact_screener_rank_2019_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_05_source_key_idx ON rankalpha.fact_screener_rank_2019_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_05_stock_key_idx ON rankalpha.fact_screener_rank_2019_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_05_style_key_idx ON rankalpha.fact_screener_rank_2019_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_06_date_key_idx ON rankalpha.fact_screener_rank_2019_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_06_pkey ON rankalpha.fact_screener_rank_2019_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_06_screening_runid_idx ON rankalpha.fact_screener_rank_2019_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_06_source_key_idx ON rankalpha.fact_screener_rank_2019_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_06_stock_key_idx ON rankalpha.fact_screener_rank_2019_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_06_style_key_idx ON rankalpha.fact_screener_rank_2019_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_07_date_key_idx ON rankalpha.fact_screener_rank_2019_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_07_pkey ON rankalpha.fact_screener_rank_2019_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_07_screening_runid_idx ON rankalpha.fact_screener_rank_2019_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_07_source_key_idx ON rankalpha.fact_screener_rank_2019_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_07_stock_key_idx ON rankalpha.fact_screener_rank_2019_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_07_style_key_idx ON rankalpha.fact_screener_rank_2019_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_08_date_key_idx ON rankalpha.fact_screener_rank_2019_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_08_pkey ON rankalpha.fact_screener_rank_2019_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_08_screening_runid_idx ON rankalpha.fact_screener_rank_2019_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_08_source_key_idx ON rankalpha.fact_screener_rank_2019_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_08_stock_key_idx ON rankalpha.fact_screener_rank_2019_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_08_style_key_idx ON rankalpha.fact_screener_rank_2019_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_09_date_key_idx ON rankalpha.fact_screener_rank_2019_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_09_pkey ON rankalpha.fact_screener_rank_2019_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_09_screening_runid_idx ON rankalpha.fact_screener_rank_2019_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_09_source_key_idx ON rankalpha.fact_screener_rank_2019_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_09_stock_key_idx ON rankalpha.fact_screener_rank_2019_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_09_style_key_idx ON rankalpha.fact_screener_rank_2019_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_10_date_key_idx ON rankalpha.fact_screener_rank_2019_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_10_pkey ON rankalpha.fact_screener_rank_2019_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_10_screening_runid_idx ON rankalpha.fact_screener_rank_2019_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_10_source_key_idx ON rankalpha.fact_screener_rank_2019_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_10_stock_key_idx ON rankalpha.fact_screener_rank_2019_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_10_style_key_idx ON rankalpha.fact_screener_rank_2019_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_11_date_key_idx ON rankalpha.fact_screener_rank_2019_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_11_pkey ON rankalpha.fact_screener_rank_2019_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_11_screening_runid_idx ON rankalpha.fact_screener_rank_2019_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_11_source_key_idx ON rankalpha.fact_screener_rank_2019_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_11_stock_key_idx ON rankalpha.fact_screener_rank_2019_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_11_style_key_idx ON rankalpha.fact_screener_rank_2019_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2019_12_date_key_idx ON rankalpha.fact_screener_rank_2019_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2019_12_pkey ON rankalpha.fact_screener_rank_2019_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2019_12_screening_runid_idx ON rankalpha.fact_screener_rank_2019_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2019_12_source_key_idx ON rankalpha.fact_screener_rank_2019_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2019_12_stock_key_idx ON rankalpha.fact_screener_rank_2019_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2019_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2019_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2019_12_style_key_idx ON rankalpha.fact_screener_rank_2019_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_01_date_key_idx ON rankalpha.fact_screener_rank_2020_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_01_pkey ON rankalpha.fact_screener_rank_2020_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_01_screening_runid_idx ON rankalpha.fact_screener_rank_2020_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_01_source_key_idx ON rankalpha.fact_screener_rank_2020_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_01_stock_key_idx ON rankalpha.fact_screener_rank_2020_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_01_style_key_idx ON rankalpha.fact_screener_rank_2020_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_02_date_key_idx ON rankalpha.fact_screener_rank_2020_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_02_pkey ON rankalpha.fact_screener_rank_2020_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_02_screening_runid_idx ON rankalpha.fact_screener_rank_2020_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_02_source_key_idx ON rankalpha.fact_screener_rank_2020_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_02_stock_key_idx ON rankalpha.fact_screener_rank_2020_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_02_style_key_idx ON rankalpha.fact_screener_rank_2020_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_03_date_key_idx ON rankalpha.fact_screener_rank_2020_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_03_pkey ON rankalpha.fact_screener_rank_2020_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_03_screening_runid_idx ON rankalpha.fact_screener_rank_2020_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_03_source_key_idx ON rankalpha.fact_screener_rank_2020_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_03_stock_key_idx ON rankalpha.fact_screener_rank_2020_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_03_style_key_idx ON rankalpha.fact_screener_rank_2020_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_04_date_key_idx ON rankalpha.fact_screener_rank_2020_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_04_pkey ON rankalpha.fact_screener_rank_2020_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_04_screening_runid_idx ON rankalpha.fact_screener_rank_2020_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_04_source_key_idx ON rankalpha.fact_screener_rank_2020_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_04_stock_key_idx ON rankalpha.fact_screener_rank_2020_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_04_style_key_idx ON rankalpha.fact_screener_rank_2020_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_05_date_key_idx ON rankalpha.fact_screener_rank_2020_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_05_pkey ON rankalpha.fact_screener_rank_2020_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_05_screening_runid_idx ON rankalpha.fact_screener_rank_2020_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_05_source_key_idx ON rankalpha.fact_screener_rank_2020_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_05_stock_key_idx ON rankalpha.fact_screener_rank_2020_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_05_style_key_idx ON rankalpha.fact_screener_rank_2020_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_06_date_key_idx ON rankalpha.fact_screener_rank_2020_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_06_pkey ON rankalpha.fact_screener_rank_2020_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_06_screening_runid_idx ON rankalpha.fact_screener_rank_2020_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_06_source_key_idx ON rankalpha.fact_screener_rank_2020_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_06_stock_key_idx ON rankalpha.fact_screener_rank_2020_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_06_style_key_idx ON rankalpha.fact_screener_rank_2020_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_07_date_key_idx ON rankalpha.fact_screener_rank_2020_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_07_pkey ON rankalpha.fact_screener_rank_2020_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_07_screening_runid_idx ON rankalpha.fact_screener_rank_2020_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_07_source_key_idx ON rankalpha.fact_screener_rank_2020_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_07_stock_key_idx ON rankalpha.fact_screener_rank_2020_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_07_style_key_idx ON rankalpha.fact_screener_rank_2020_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_08_date_key_idx ON rankalpha.fact_screener_rank_2020_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_08_pkey ON rankalpha.fact_screener_rank_2020_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_08_screening_runid_idx ON rankalpha.fact_screener_rank_2020_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_08_source_key_idx ON rankalpha.fact_screener_rank_2020_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_08_stock_key_idx ON rankalpha.fact_screener_rank_2020_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_08_style_key_idx ON rankalpha.fact_screener_rank_2020_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_09_date_key_idx ON rankalpha.fact_screener_rank_2020_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_09_pkey ON rankalpha.fact_screener_rank_2020_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_09_screening_runid_idx ON rankalpha.fact_screener_rank_2020_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_09_source_key_idx ON rankalpha.fact_screener_rank_2020_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_09_stock_key_idx ON rankalpha.fact_screener_rank_2020_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_09_style_key_idx ON rankalpha.fact_screener_rank_2020_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_10_date_key_idx ON rankalpha.fact_screener_rank_2020_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_10_pkey ON rankalpha.fact_screener_rank_2020_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_10_screening_runid_idx ON rankalpha.fact_screener_rank_2020_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_10_source_key_idx ON rankalpha.fact_screener_rank_2020_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_10_stock_key_idx ON rankalpha.fact_screener_rank_2020_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_10_style_key_idx ON rankalpha.fact_screener_rank_2020_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_11_date_key_idx ON rankalpha.fact_screener_rank_2020_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_11_pkey ON rankalpha.fact_screener_rank_2020_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_11_screening_runid_idx ON rankalpha.fact_screener_rank_2020_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_11_source_key_idx ON rankalpha.fact_screener_rank_2020_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_11_stock_key_idx ON rankalpha.fact_screener_rank_2020_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_11_style_key_idx ON rankalpha.fact_screener_rank_2020_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2020_12_date_key_idx ON rankalpha.fact_screener_rank_2020_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2020_12_pkey ON rankalpha.fact_screener_rank_2020_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2020_12_screening_runid_idx ON rankalpha.fact_screener_rank_2020_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2020_12_source_key_idx ON rankalpha.fact_screener_rank_2020_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2020_12_stock_key_idx ON rankalpha.fact_screener_rank_2020_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2020_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2020_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2020_12_style_key_idx ON rankalpha.fact_screener_rank_2020_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_01_date_key_idx ON rankalpha.fact_screener_rank_2021_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_01_pkey ON rankalpha.fact_screener_rank_2021_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_01_screening_runid_idx ON rankalpha.fact_screener_rank_2021_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_01_source_key_idx ON rankalpha.fact_screener_rank_2021_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_01_stock_key_idx ON rankalpha.fact_screener_rank_2021_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_01_style_key_idx ON rankalpha.fact_screener_rank_2021_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_02_date_key_idx ON rankalpha.fact_screener_rank_2021_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_02_pkey ON rankalpha.fact_screener_rank_2021_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_02_screening_runid_idx ON rankalpha.fact_screener_rank_2021_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_02_source_key_idx ON rankalpha.fact_screener_rank_2021_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_02_stock_key_idx ON rankalpha.fact_screener_rank_2021_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_02_style_key_idx ON rankalpha.fact_screener_rank_2021_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_03_date_key_idx ON rankalpha.fact_screener_rank_2021_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_03_pkey ON rankalpha.fact_screener_rank_2021_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_03_screening_runid_idx ON rankalpha.fact_screener_rank_2021_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_03_source_key_idx ON rankalpha.fact_screener_rank_2021_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_03_stock_key_idx ON rankalpha.fact_screener_rank_2021_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_03_style_key_idx ON rankalpha.fact_screener_rank_2021_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_04_date_key_idx ON rankalpha.fact_screener_rank_2021_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_04_pkey ON rankalpha.fact_screener_rank_2021_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_04_screening_runid_idx ON rankalpha.fact_screener_rank_2021_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_04_source_key_idx ON rankalpha.fact_screener_rank_2021_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_04_stock_key_idx ON rankalpha.fact_screener_rank_2021_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_04_style_key_idx ON rankalpha.fact_screener_rank_2021_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_05_date_key_idx ON rankalpha.fact_screener_rank_2021_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_05_pkey ON rankalpha.fact_screener_rank_2021_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_05_screening_runid_idx ON rankalpha.fact_screener_rank_2021_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_05_source_key_idx ON rankalpha.fact_screener_rank_2021_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_05_stock_key_idx ON rankalpha.fact_screener_rank_2021_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_05_style_key_idx ON rankalpha.fact_screener_rank_2021_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_06_date_key_idx ON rankalpha.fact_screener_rank_2021_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_06_pkey ON rankalpha.fact_screener_rank_2021_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_06_screening_runid_idx ON rankalpha.fact_screener_rank_2021_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_06_source_key_idx ON rankalpha.fact_screener_rank_2021_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_06_stock_key_idx ON rankalpha.fact_screener_rank_2021_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_06_style_key_idx ON rankalpha.fact_screener_rank_2021_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_07_date_key_idx ON rankalpha.fact_screener_rank_2021_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_07_pkey ON rankalpha.fact_screener_rank_2021_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_07_screening_runid_idx ON rankalpha.fact_screener_rank_2021_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_07_source_key_idx ON rankalpha.fact_screener_rank_2021_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_07_stock_key_idx ON rankalpha.fact_screener_rank_2021_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_07_style_key_idx ON rankalpha.fact_screener_rank_2021_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_08_date_key_idx ON rankalpha.fact_screener_rank_2021_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_08_pkey ON rankalpha.fact_screener_rank_2021_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_08_screening_runid_idx ON rankalpha.fact_screener_rank_2021_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_08_source_key_idx ON rankalpha.fact_screener_rank_2021_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_08_stock_key_idx ON rankalpha.fact_screener_rank_2021_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_08_style_key_idx ON rankalpha.fact_screener_rank_2021_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_09_date_key_idx ON rankalpha.fact_screener_rank_2021_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_09_pkey ON rankalpha.fact_screener_rank_2021_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_09_screening_runid_idx ON rankalpha.fact_screener_rank_2021_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_09_source_key_idx ON rankalpha.fact_screener_rank_2021_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_09_stock_key_idx ON rankalpha.fact_screener_rank_2021_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_09_style_key_idx ON rankalpha.fact_screener_rank_2021_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_10_date_key_idx ON rankalpha.fact_screener_rank_2021_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_10_pkey ON rankalpha.fact_screener_rank_2021_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_10_screening_runid_idx ON rankalpha.fact_screener_rank_2021_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_10_source_key_idx ON rankalpha.fact_screener_rank_2021_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_10_stock_key_idx ON rankalpha.fact_screener_rank_2021_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_10_style_key_idx ON rankalpha.fact_screener_rank_2021_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_11_date_key_idx ON rankalpha.fact_screener_rank_2021_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_11_pkey ON rankalpha.fact_screener_rank_2021_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_11_screening_runid_idx ON rankalpha.fact_screener_rank_2021_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_11_source_key_idx ON rankalpha.fact_screener_rank_2021_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_11_stock_key_idx ON rankalpha.fact_screener_rank_2021_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_11_style_key_idx ON rankalpha.fact_screener_rank_2021_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2021_12_date_key_idx ON rankalpha.fact_screener_rank_2021_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2021_12_pkey ON rankalpha.fact_screener_rank_2021_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2021_12_screening_runid_idx ON rankalpha.fact_screener_rank_2021_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2021_12_source_key_idx ON rankalpha.fact_screener_rank_2021_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2021_12_stock_key_idx ON rankalpha.fact_screener_rank_2021_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2021_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2021_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2021_12_style_key_idx ON rankalpha.fact_screener_rank_2021_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_01_date_key_idx ON rankalpha.fact_screener_rank_2022_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_01_pkey ON rankalpha.fact_screener_rank_2022_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_01_screening_runid_idx ON rankalpha.fact_screener_rank_2022_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_01_source_key_idx ON rankalpha.fact_screener_rank_2022_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_01_stock_key_idx ON rankalpha.fact_screener_rank_2022_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_01_style_key_idx ON rankalpha.fact_screener_rank_2022_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_02_date_key_idx ON rankalpha.fact_screener_rank_2022_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_02_pkey ON rankalpha.fact_screener_rank_2022_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_02_screening_runid_idx ON rankalpha.fact_screener_rank_2022_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_02_source_key_idx ON rankalpha.fact_screener_rank_2022_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_02_stock_key_idx ON rankalpha.fact_screener_rank_2022_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_02_style_key_idx ON rankalpha.fact_screener_rank_2022_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_03_date_key_idx ON rankalpha.fact_screener_rank_2022_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_03_pkey ON rankalpha.fact_screener_rank_2022_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_03_screening_runid_idx ON rankalpha.fact_screener_rank_2022_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_03_source_key_idx ON rankalpha.fact_screener_rank_2022_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_03_stock_key_idx ON rankalpha.fact_screener_rank_2022_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_03_style_key_idx ON rankalpha.fact_screener_rank_2022_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_04_date_key_idx ON rankalpha.fact_screener_rank_2022_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_04_pkey ON rankalpha.fact_screener_rank_2022_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_04_screening_runid_idx ON rankalpha.fact_screener_rank_2022_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_04_source_key_idx ON rankalpha.fact_screener_rank_2022_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_04_stock_key_idx ON rankalpha.fact_screener_rank_2022_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_04_style_key_idx ON rankalpha.fact_screener_rank_2022_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_05_date_key_idx ON rankalpha.fact_screener_rank_2022_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_05_pkey ON rankalpha.fact_screener_rank_2022_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_05_screening_runid_idx ON rankalpha.fact_screener_rank_2022_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_05_source_key_idx ON rankalpha.fact_screener_rank_2022_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_05_stock_key_idx ON rankalpha.fact_screener_rank_2022_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_05_style_key_idx ON rankalpha.fact_screener_rank_2022_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_06_date_key_idx ON rankalpha.fact_screener_rank_2022_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_06_pkey ON rankalpha.fact_screener_rank_2022_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_06_screening_runid_idx ON rankalpha.fact_screener_rank_2022_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_06_source_key_idx ON rankalpha.fact_screener_rank_2022_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_06_stock_key_idx ON rankalpha.fact_screener_rank_2022_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_06_style_key_idx ON rankalpha.fact_screener_rank_2022_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_07_date_key_idx ON rankalpha.fact_screener_rank_2022_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_07_pkey ON rankalpha.fact_screener_rank_2022_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_07_screening_runid_idx ON rankalpha.fact_screener_rank_2022_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_07_source_key_idx ON rankalpha.fact_screener_rank_2022_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_07_stock_key_idx ON rankalpha.fact_screener_rank_2022_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_07_style_key_idx ON rankalpha.fact_screener_rank_2022_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_08_date_key_idx ON rankalpha.fact_screener_rank_2022_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_08_pkey ON rankalpha.fact_screener_rank_2022_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_08_screening_runid_idx ON rankalpha.fact_screener_rank_2022_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_08_source_key_idx ON rankalpha.fact_screener_rank_2022_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_08_stock_key_idx ON rankalpha.fact_screener_rank_2022_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_08_style_key_idx ON rankalpha.fact_screener_rank_2022_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_09_date_key_idx ON rankalpha.fact_screener_rank_2022_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_09_pkey ON rankalpha.fact_screener_rank_2022_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_09_screening_runid_idx ON rankalpha.fact_screener_rank_2022_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_09_source_key_idx ON rankalpha.fact_screener_rank_2022_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_09_stock_key_idx ON rankalpha.fact_screener_rank_2022_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_09_style_key_idx ON rankalpha.fact_screener_rank_2022_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_10_date_key_idx ON rankalpha.fact_screener_rank_2022_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_10_pkey ON rankalpha.fact_screener_rank_2022_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_10_screening_runid_idx ON rankalpha.fact_screener_rank_2022_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_10_source_key_idx ON rankalpha.fact_screener_rank_2022_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_10_stock_key_idx ON rankalpha.fact_screener_rank_2022_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_10_style_key_idx ON rankalpha.fact_screener_rank_2022_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_11_date_key_idx ON rankalpha.fact_screener_rank_2022_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_11_pkey ON rankalpha.fact_screener_rank_2022_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_11_screening_runid_idx ON rankalpha.fact_screener_rank_2022_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_11_source_key_idx ON rankalpha.fact_screener_rank_2022_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_11_stock_key_idx ON rankalpha.fact_screener_rank_2022_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_11_style_key_idx ON rankalpha.fact_screener_rank_2022_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2022_12_date_key_idx ON rankalpha.fact_screener_rank_2022_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2022_12_pkey ON rankalpha.fact_screener_rank_2022_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2022_12_screening_runid_idx ON rankalpha.fact_screener_rank_2022_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2022_12_source_key_idx ON rankalpha.fact_screener_rank_2022_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2022_12_stock_key_idx ON rankalpha.fact_screener_rank_2022_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2022_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2022_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2022_12_style_key_idx ON rankalpha.fact_screener_rank_2022_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_01_date_key_idx ON rankalpha.fact_screener_rank_2023_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_01_pkey ON rankalpha.fact_screener_rank_2023_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_01_screening_runid_idx ON rankalpha.fact_screener_rank_2023_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_01_source_key_idx ON rankalpha.fact_screener_rank_2023_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_01_stock_key_idx ON rankalpha.fact_screener_rank_2023_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_01_style_key_idx ON rankalpha.fact_screener_rank_2023_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_02_date_key_idx ON rankalpha.fact_screener_rank_2023_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_02_pkey ON rankalpha.fact_screener_rank_2023_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_02_screening_runid_idx ON rankalpha.fact_screener_rank_2023_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_02_source_key_idx ON rankalpha.fact_screener_rank_2023_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_02_stock_key_idx ON rankalpha.fact_screener_rank_2023_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_02_style_key_idx ON rankalpha.fact_screener_rank_2023_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_03_date_key_idx ON rankalpha.fact_screener_rank_2023_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_03_pkey ON rankalpha.fact_screener_rank_2023_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_03_screening_runid_idx ON rankalpha.fact_screener_rank_2023_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_03_source_key_idx ON rankalpha.fact_screener_rank_2023_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_03_stock_key_idx ON rankalpha.fact_screener_rank_2023_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_03_style_key_idx ON rankalpha.fact_screener_rank_2023_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_04_date_key_idx ON rankalpha.fact_screener_rank_2023_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_04_pkey ON rankalpha.fact_screener_rank_2023_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_04_screening_runid_idx ON rankalpha.fact_screener_rank_2023_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_04_source_key_idx ON rankalpha.fact_screener_rank_2023_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_04_stock_key_idx ON rankalpha.fact_screener_rank_2023_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_04_style_key_idx ON rankalpha.fact_screener_rank_2023_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_05_date_key_idx ON rankalpha.fact_screener_rank_2023_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_05_pkey ON rankalpha.fact_screener_rank_2023_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_05_screening_runid_idx ON rankalpha.fact_screener_rank_2023_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_05_source_key_idx ON rankalpha.fact_screener_rank_2023_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_05_stock_key_idx ON rankalpha.fact_screener_rank_2023_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_05_style_key_idx ON rankalpha.fact_screener_rank_2023_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_06_date_key_idx ON rankalpha.fact_screener_rank_2023_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_06_pkey ON rankalpha.fact_screener_rank_2023_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_06_screening_runid_idx ON rankalpha.fact_screener_rank_2023_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_06_source_key_idx ON rankalpha.fact_screener_rank_2023_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_06_stock_key_idx ON rankalpha.fact_screener_rank_2023_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_06_style_key_idx ON rankalpha.fact_screener_rank_2023_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_07_date_key_idx ON rankalpha.fact_screener_rank_2023_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_07_pkey ON rankalpha.fact_screener_rank_2023_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_07_screening_runid_idx ON rankalpha.fact_screener_rank_2023_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_07_source_key_idx ON rankalpha.fact_screener_rank_2023_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_07_stock_key_idx ON rankalpha.fact_screener_rank_2023_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_07_style_key_idx ON rankalpha.fact_screener_rank_2023_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_08_date_key_idx ON rankalpha.fact_screener_rank_2023_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_08_pkey ON rankalpha.fact_screener_rank_2023_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_08_screening_runid_idx ON rankalpha.fact_screener_rank_2023_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_08_source_key_idx ON rankalpha.fact_screener_rank_2023_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_08_stock_key_idx ON rankalpha.fact_screener_rank_2023_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_08_style_key_idx ON rankalpha.fact_screener_rank_2023_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_09_date_key_idx ON rankalpha.fact_screener_rank_2023_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_09_pkey ON rankalpha.fact_screener_rank_2023_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_09_screening_runid_idx ON rankalpha.fact_screener_rank_2023_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_09_source_key_idx ON rankalpha.fact_screener_rank_2023_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_09_stock_key_idx ON rankalpha.fact_screener_rank_2023_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_09_style_key_idx ON rankalpha.fact_screener_rank_2023_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_10_date_key_idx ON rankalpha.fact_screener_rank_2023_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_10_pkey ON rankalpha.fact_screener_rank_2023_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_10_screening_runid_idx ON rankalpha.fact_screener_rank_2023_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_10_source_key_idx ON rankalpha.fact_screener_rank_2023_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_10_stock_key_idx ON rankalpha.fact_screener_rank_2023_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_10_style_key_idx ON rankalpha.fact_screener_rank_2023_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_11_date_key_idx ON rankalpha.fact_screener_rank_2023_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_11_pkey ON rankalpha.fact_screener_rank_2023_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_11_screening_runid_idx ON rankalpha.fact_screener_rank_2023_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_11_source_key_idx ON rankalpha.fact_screener_rank_2023_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_11_stock_key_idx ON rankalpha.fact_screener_rank_2023_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_11_style_key_idx ON rankalpha.fact_screener_rank_2023_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2023_12_date_key_idx ON rankalpha.fact_screener_rank_2023_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2023_12_pkey ON rankalpha.fact_screener_rank_2023_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2023_12_screening_runid_idx ON rankalpha.fact_screener_rank_2023_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2023_12_source_key_idx ON rankalpha.fact_screener_rank_2023_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2023_12_stock_key_idx ON rankalpha.fact_screener_rank_2023_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2023_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2023_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2023_12_style_key_idx ON rankalpha.fact_screener_rank_2023_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_01_date_key_idx ON rankalpha.fact_screener_rank_2024_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_01_pkey ON rankalpha.fact_screener_rank_2024_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_01_screening_runid_idx ON rankalpha.fact_screener_rank_2024_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_01_source_key_idx ON rankalpha.fact_screener_rank_2024_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_01_stock_key_idx ON rankalpha.fact_screener_rank_2024_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_01_style_key_idx ON rankalpha.fact_screener_rank_2024_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_02_date_key_idx ON rankalpha.fact_screener_rank_2024_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_02_pkey ON rankalpha.fact_screener_rank_2024_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_02_screening_runid_idx ON rankalpha.fact_screener_rank_2024_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_02_source_key_idx ON rankalpha.fact_screener_rank_2024_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_02_stock_key_idx ON rankalpha.fact_screener_rank_2024_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_02_style_key_idx ON rankalpha.fact_screener_rank_2024_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_03_date_key_idx ON rankalpha.fact_screener_rank_2024_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_03_pkey ON rankalpha.fact_screener_rank_2024_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_03_screening_runid_idx ON rankalpha.fact_screener_rank_2024_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_03_source_key_idx ON rankalpha.fact_screener_rank_2024_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_03_stock_key_idx ON rankalpha.fact_screener_rank_2024_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_03_style_key_idx ON rankalpha.fact_screener_rank_2024_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_04_date_key_idx ON rankalpha.fact_screener_rank_2024_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_04_pkey ON rankalpha.fact_screener_rank_2024_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_04_screening_runid_idx ON rankalpha.fact_screener_rank_2024_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_04_source_key_idx ON rankalpha.fact_screener_rank_2024_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_04_stock_key_idx ON rankalpha.fact_screener_rank_2024_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_04_style_key_idx ON rankalpha.fact_screener_rank_2024_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_05_date_key_idx ON rankalpha.fact_screener_rank_2024_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_05_pkey ON rankalpha.fact_screener_rank_2024_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_05_screening_runid_idx ON rankalpha.fact_screener_rank_2024_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_05_source_key_idx ON rankalpha.fact_screener_rank_2024_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_05_stock_key_idx ON rankalpha.fact_screener_rank_2024_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_05_style_key_idx ON rankalpha.fact_screener_rank_2024_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_06_date_key_idx ON rankalpha.fact_screener_rank_2024_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_06_pkey ON rankalpha.fact_screener_rank_2024_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_06_screening_runid_idx ON rankalpha.fact_screener_rank_2024_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_06_source_key_idx ON rankalpha.fact_screener_rank_2024_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_06_stock_key_idx ON rankalpha.fact_screener_rank_2024_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_06_style_key_idx ON rankalpha.fact_screener_rank_2024_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_07_date_key_idx ON rankalpha.fact_screener_rank_2024_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_07_pkey ON rankalpha.fact_screener_rank_2024_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_07_screening_runid_idx ON rankalpha.fact_screener_rank_2024_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_07_source_key_idx ON rankalpha.fact_screener_rank_2024_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_07_stock_key_idx ON rankalpha.fact_screener_rank_2024_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_07_style_key_idx ON rankalpha.fact_screener_rank_2024_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_08_date_key_idx ON rankalpha.fact_screener_rank_2024_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_08_pkey ON rankalpha.fact_screener_rank_2024_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_08_screening_runid_idx ON rankalpha.fact_screener_rank_2024_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_08_source_key_idx ON rankalpha.fact_screener_rank_2024_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_08_stock_key_idx ON rankalpha.fact_screener_rank_2024_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_08_style_key_idx ON rankalpha.fact_screener_rank_2024_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_09_date_key_idx ON rankalpha.fact_screener_rank_2024_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_09_pkey ON rankalpha.fact_screener_rank_2024_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_09_screening_runid_idx ON rankalpha.fact_screener_rank_2024_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_09_source_key_idx ON rankalpha.fact_screener_rank_2024_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_09_stock_key_idx ON rankalpha.fact_screener_rank_2024_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_09_style_key_idx ON rankalpha.fact_screener_rank_2024_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_10_date_key_idx ON rankalpha.fact_screener_rank_2024_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_10_pkey ON rankalpha.fact_screener_rank_2024_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_10_screening_runid_idx ON rankalpha.fact_screener_rank_2024_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_10_source_key_idx ON rankalpha.fact_screener_rank_2024_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_10_stock_key_idx ON rankalpha.fact_screener_rank_2024_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_10_style_key_idx ON rankalpha.fact_screener_rank_2024_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_11_date_key_idx ON rankalpha.fact_screener_rank_2024_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_11_pkey ON rankalpha.fact_screener_rank_2024_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_11_screening_runid_idx ON rankalpha.fact_screener_rank_2024_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_11_source_key_idx ON rankalpha.fact_screener_rank_2024_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_11_stock_key_idx ON rankalpha.fact_screener_rank_2024_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_11_style_key_idx ON rankalpha.fact_screener_rank_2024_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2024_12_date_key_idx ON rankalpha.fact_screener_rank_2024_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2024_12_pkey ON rankalpha.fact_screener_rank_2024_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2024_12_screening_runid_idx ON rankalpha.fact_screener_rank_2024_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2024_12_source_key_idx ON rankalpha.fact_screener_rank_2024_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2024_12_stock_key_idx ON rankalpha.fact_screener_rank_2024_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2024_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2024_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2024_12_style_key_idx ON rankalpha.fact_screener_rank_2024_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_01_date_key_idx ON rankalpha.fact_screener_rank_2025_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_01_pkey ON rankalpha.fact_screener_rank_2025_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_01_screening_runid_idx ON rankalpha.fact_screener_rank_2025_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_01_source_key_idx ON rankalpha.fact_screener_rank_2025_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_01_stock_key_idx ON rankalpha.fact_screener_rank_2025_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_01_style_key_idx ON rankalpha.fact_screener_rank_2025_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_02_date_key_idx ON rankalpha.fact_screener_rank_2025_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_02_pkey ON rankalpha.fact_screener_rank_2025_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_02_screening_runid_idx ON rankalpha.fact_screener_rank_2025_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_02_source_key_idx ON rankalpha.fact_screener_rank_2025_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_02_stock_key_idx ON rankalpha.fact_screener_rank_2025_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_02_style_key_idx ON rankalpha.fact_screener_rank_2025_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_03_date_key_idx ON rankalpha.fact_screener_rank_2025_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_03_pkey ON rankalpha.fact_screener_rank_2025_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_03_screening_runid_idx ON rankalpha.fact_screener_rank_2025_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_03_source_key_idx ON rankalpha.fact_screener_rank_2025_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_03_stock_key_idx ON rankalpha.fact_screener_rank_2025_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_03_style_key_idx ON rankalpha.fact_screener_rank_2025_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_04_date_key_idx ON rankalpha.fact_screener_rank_2025_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_04_pkey ON rankalpha.fact_screener_rank_2025_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_04_screening_runid_idx ON rankalpha.fact_screener_rank_2025_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_04_source_key_idx ON rankalpha.fact_screener_rank_2025_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_04_stock_key_idx ON rankalpha.fact_screener_rank_2025_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_04_style_key_idx ON rankalpha.fact_screener_rank_2025_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_05_date_key_idx ON rankalpha.fact_screener_rank_2025_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_05_pkey ON rankalpha.fact_screener_rank_2025_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_05_screening_runid_idx ON rankalpha.fact_screener_rank_2025_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_05_source_key_idx ON rankalpha.fact_screener_rank_2025_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_05_stock_key_idx ON rankalpha.fact_screener_rank_2025_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_05_style_key_idx ON rankalpha.fact_screener_rank_2025_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_06_date_key_idx ON rankalpha.fact_screener_rank_2025_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_06_pkey ON rankalpha.fact_screener_rank_2025_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_06_screening_runid_idx ON rankalpha.fact_screener_rank_2025_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_06_source_key_idx ON rankalpha.fact_screener_rank_2025_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_06_stock_key_idx ON rankalpha.fact_screener_rank_2025_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_06_style_key_idx ON rankalpha.fact_screener_rank_2025_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_07_date_key_idx ON rankalpha.fact_screener_rank_2025_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_07_pkey ON rankalpha.fact_screener_rank_2025_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_07_screening_runid_idx ON rankalpha.fact_screener_rank_2025_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_07_source_key_idx ON rankalpha.fact_screener_rank_2025_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_07_stock_key_idx ON rankalpha.fact_screener_rank_2025_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_07_style_key_idx ON rankalpha.fact_screener_rank_2025_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_08_date_key_idx ON rankalpha.fact_screener_rank_2025_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_08_pkey ON rankalpha.fact_screener_rank_2025_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_08_screening_runid_idx ON rankalpha.fact_screener_rank_2025_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_08_source_key_idx ON rankalpha.fact_screener_rank_2025_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_08_stock_key_idx ON rankalpha.fact_screener_rank_2025_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_08_style_key_idx ON rankalpha.fact_screener_rank_2025_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_09_date_key_idx ON rankalpha.fact_screener_rank_2025_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_09_pkey ON rankalpha.fact_screener_rank_2025_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_09_screening_runid_idx ON rankalpha.fact_screener_rank_2025_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_09_source_key_idx ON rankalpha.fact_screener_rank_2025_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_09_stock_key_idx ON rankalpha.fact_screener_rank_2025_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_09_style_key_idx ON rankalpha.fact_screener_rank_2025_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_10_date_key_idx ON rankalpha.fact_screener_rank_2025_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_10_pkey ON rankalpha.fact_screener_rank_2025_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_10_screening_runid_idx ON rankalpha.fact_screener_rank_2025_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_10_source_key_idx ON rankalpha.fact_screener_rank_2025_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_10_stock_key_idx ON rankalpha.fact_screener_rank_2025_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_10_style_key_idx ON rankalpha.fact_screener_rank_2025_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_11_date_key_idx ON rankalpha.fact_screener_rank_2025_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_11_pkey ON rankalpha.fact_screener_rank_2025_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_11_screening_runid_idx ON rankalpha.fact_screener_rank_2025_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_11_source_key_idx ON rankalpha.fact_screener_rank_2025_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_11_stock_key_idx ON rankalpha.fact_screener_rank_2025_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_11_style_key_idx ON rankalpha.fact_screener_rank_2025_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2025_12_date_key_idx ON rankalpha.fact_screener_rank_2025_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2025_12_pkey ON rankalpha.fact_screener_rank_2025_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2025_12_screening_runid_idx ON rankalpha.fact_screener_rank_2025_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2025_12_source_key_idx ON rankalpha.fact_screener_rank_2025_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2025_12_stock_key_idx ON rankalpha.fact_screener_rank_2025_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2025_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2025_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2025_12_style_key_idx ON rankalpha.fact_screener_rank_2025_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_01_date_key_idx ON rankalpha.fact_screener_rank_2026_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_01_pkey ON rankalpha.fact_screener_rank_2026_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_01_screening_runid_idx ON rankalpha.fact_screener_rank_2026_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_01_source_key_idx ON rankalpha.fact_screener_rank_2026_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_01_stock_key_idx ON rankalpha.fact_screener_rank_2026_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_01_style_key_idx ON rankalpha.fact_screener_rank_2026_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_02_date_key_idx ON rankalpha.fact_screener_rank_2026_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_02_pkey ON rankalpha.fact_screener_rank_2026_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_02_screening_runid_idx ON rankalpha.fact_screener_rank_2026_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_02_source_key_idx ON rankalpha.fact_screener_rank_2026_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_02_stock_key_idx ON rankalpha.fact_screener_rank_2026_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_02_style_key_idx ON rankalpha.fact_screener_rank_2026_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_03_date_key_idx ON rankalpha.fact_screener_rank_2026_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_03_pkey ON rankalpha.fact_screener_rank_2026_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_03_screening_runid_idx ON rankalpha.fact_screener_rank_2026_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_03_source_key_idx ON rankalpha.fact_screener_rank_2026_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_03_stock_key_idx ON rankalpha.fact_screener_rank_2026_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_03_style_key_idx ON rankalpha.fact_screener_rank_2026_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_04_date_key_idx ON rankalpha.fact_screener_rank_2026_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_04_pkey ON rankalpha.fact_screener_rank_2026_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_04_screening_runid_idx ON rankalpha.fact_screener_rank_2026_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_04_source_key_idx ON rankalpha.fact_screener_rank_2026_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_04_stock_key_idx ON rankalpha.fact_screener_rank_2026_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_04_style_key_idx ON rankalpha.fact_screener_rank_2026_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_05_date_key_idx ON rankalpha.fact_screener_rank_2026_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_05_pkey ON rankalpha.fact_screener_rank_2026_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_05_screening_runid_idx ON rankalpha.fact_screener_rank_2026_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_05_source_key_idx ON rankalpha.fact_screener_rank_2026_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_05_stock_key_idx ON rankalpha.fact_screener_rank_2026_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_05_style_key_idx ON rankalpha.fact_screener_rank_2026_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_06_date_key_idx ON rankalpha.fact_screener_rank_2026_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_06_pkey ON rankalpha.fact_screener_rank_2026_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_06_screening_runid_idx ON rankalpha.fact_screener_rank_2026_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_06_source_key_idx ON rankalpha.fact_screener_rank_2026_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_06_stock_key_idx ON rankalpha.fact_screener_rank_2026_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_06_style_key_idx ON rankalpha.fact_screener_rank_2026_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_07_date_key_idx ON rankalpha.fact_screener_rank_2026_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_07_pkey ON rankalpha.fact_screener_rank_2026_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_07_screening_runid_idx ON rankalpha.fact_screener_rank_2026_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_07_source_key_idx ON rankalpha.fact_screener_rank_2026_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_07_stock_key_idx ON rankalpha.fact_screener_rank_2026_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_07_style_key_idx ON rankalpha.fact_screener_rank_2026_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_08_date_key_idx ON rankalpha.fact_screener_rank_2026_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_08_pkey ON rankalpha.fact_screener_rank_2026_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_08_screening_runid_idx ON rankalpha.fact_screener_rank_2026_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_08_source_key_idx ON rankalpha.fact_screener_rank_2026_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_08_stock_key_idx ON rankalpha.fact_screener_rank_2026_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_08_style_key_idx ON rankalpha.fact_screener_rank_2026_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_09_date_key_idx ON rankalpha.fact_screener_rank_2026_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_09_pkey ON rankalpha.fact_screener_rank_2026_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_09_screening_runid_idx ON rankalpha.fact_screener_rank_2026_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_09_source_key_idx ON rankalpha.fact_screener_rank_2026_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_09_stock_key_idx ON rankalpha.fact_screener_rank_2026_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_09_style_key_idx ON rankalpha.fact_screener_rank_2026_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_10_date_key_idx ON rankalpha.fact_screener_rank_2026_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_10_pkey ON rankalpha.fact_screener_rank_2026_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_10_screening_runid_idx ON rankalpha.fact_screener_rank_2026_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_10_source_key_idx ON rankalpha.fact_screener_rank_2026_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_10_stock_key_idx ON rankalpha.fact_screener_rank_2026_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_10_style_key_idx ON rankalpha.fact_screener_rank_2026_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_11_date_key_idx ON rankalpha.fact_screener_rank_2026_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_11_pkey ON rankalpha.fact_screener_rank_2026_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_11_screening_runid_idx ON rankalpha.fact_screener_rank_2026_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_11_source_key_idx ON rankalpha.fact_screener_rank_2026_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_11_stock_key_idx ON rankalpha.fact_screener_rank_2026_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_11_style_key_idx ON rankalpha.fact_screener_rank_2026_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2026_12_date_key_idx ON rankalpha.fact_screener_rank_2026_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2026_12_pkey ON rankalpha.fact_screener_rank_2026_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2026_12_screening_runid_idx ON rankalpha.fact_screener_rank_2026_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2026_12_source_key_idx ON rankalpha.fact_screener_rank_2026_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2026_12_stock_key_idx ON rankalpha.fact_screener_rank_2026_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2026_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2026_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2026_12_style_key_idx ON rankalpha.fact_screener_rank_2026_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_01_date_key_idx ON rankalpha.fact_screener_rank_2027_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_01_pkey ON rankalpha.fact_screener_rank_2027_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_01_screening_runid_idx ON rankalpha.fact_screener_rank_2027_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_01_source_key_idx ON rankalpha.fact_screener_rank_2027_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_01_stock_key_idx ON rankalpha.fact_screener_rank_2027_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_01_style_key_idx ON rankalpha.fact_screener_rank_2027_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_02_date_key_idx ON rankalpha.fact_screener_rank_2027_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_02_pkey ON rankalpha.fact_screener_rank_2027_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_02_screening_runid_idx ON rankalpha.fact_screener_rank_2027_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_02_source_key_idx ON rankalpha.fact_screener_rank_2027_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_02_stock_key_idx ON rankalpha.fact_screener_rank_2027_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_02_style_key_idx ON rankalpha.fact_screener_rank_2027_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_03_date_key_idx ON rankalpha.fact_screener_rank_2027_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_03_pkey ON rankalpha.fact_screener_rank_2027_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_03_screening_runid_idx ON rankalpha.fact_screener_rank_2027_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_03_source_key_idx ON rankalpha.fact_screener_rank_2027_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_03_stock_key_idx ON rankalpha.fact_screener_rank_2027_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_03_style_key_idx ON rankalpha.fact_screener_rank_2027_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_04_date_key_idx ON rankalpha.fact_screener_rank_2027_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_04_pkey ON rankalpha.fact_screener_rank_2027_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_04_screening_runid_idx ON rankalpha.fact_screener_rank_2027_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_04_source_key_idx ON rankalpha.fact_screener_rank_2027_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_04_stock_key_idx ON rankalpha.fact_screener_rank_2027_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_04_style_key_idx ON rankalpha.fact_screener_rank_2027_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_05_date_key_idx ON rankalpha.fact_screener_rank_2027_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_05_pkey ON rankalpha.fact_screener_rank_2027_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_05_screening_runid_idx ON rankalpha.fact_screener_rank_2027_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_05_source_key_idx ON rankalpha.fact_screener_rank_2027_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_05_stock_key_idx ON rankalpha.fact_screener_rank_2027_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_05_style_key_idx ON rankalpha.fact_screener_rank_2027_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_06_date_key_idx ON rankalpha.fact_screener_rank_2027_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_06_pkey ON rankalpha.fact_screener_rank_2027_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_06_screening_runid_idx ON rankalpha.fact_screener_rank_2027_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_06_source_key_idx ON rankalpha.fact_screener_rank_2027_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_06_stock_key_idx ON rankalpha.fact_screener_rank_2027_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_06_style_key_idx ON rankalpha.fact_screener_rank_2027_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_07_date_key_idx ON rankalpha.fact_screener_rank_2027_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_07_pkey ON rankalpha.fact_screener_rank_2027_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_07_screening_runid_idx ON rankalpha.fact_screener_rank_2027_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_07_source_key_idx ON rankalpha.fact_screener_rank_2027_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_07_stock_key_idx ON rankalpha.fact_screener_rank_2027_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_07_style_key_idx ON rankalpha.fact_screener_rank_2027_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_08_date_key_idx ON rankalpha.fact_screener_rank_2027_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_08_pkey ON rankalpha.fact_screener_rank_2027_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_08_screening_runid_idx ON rankalpha.fact_screener_rank_2027_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_08_source_key_idx ON rankalpha.fact_screener_rank_2027_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_08_stock_key_idx ON rankalpha.fact_screener_rank_2027_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_08_style_key_idx ON rankalpha.fact_screener_rank_2027_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_09_date_key_idx ON rankalpha.fact_screener_rank_2027_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_09_pkey ON rankalpha.fact_screener_rank_2027_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_09_screening_runid_idx ON rankalpha.fact_screener_rank_2027_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_09_source_key_idx ON rankalpha.fact_screener_rank_2027_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_09_stock_key_idx ON rankalpha.fact_screener_rank_2027_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_09_style_key_idx ON rankalpha.fact_screener_rank_2027_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_10_date_key_idx ON rankalpha.fact_screener_rank_2027_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_10_pkey ON rankalpha.fact_screener_rank_2027_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_10_screening_runid_idx ON rankalpha.fact_screener_rank_2027_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_10_source_key_idx ON rankalpha.fact_screener_rank_2027_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_10_stock_key_idx ON rankalpha.fact_screener_rank_2027_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_10_style_key_idx ON rankalpha.fact_screener_rank_2027_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_11_date_key_idx ON rankalpha.fact_screener_rank_2027_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_11_pkey ON rankalpha.fact_screener_rank_2027_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_11_screening_runid_idx ON rankalpha.fact_screener_rank_2027_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_11_source_key_idx ON rankalpha.fact_screener_rank_2027_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_11_stock_key_idx ON rankalpha.fact_screener_rank_2027_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_11_style_key_idx ON rankalpha.fact_screener_rank_2027_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2027_12_date_key_idx ON rankalpha.fact_screener_rank_2027_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2027_12_pkey ON rankalpha.fact_screener_rank_2027_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2027_12_screening_runid_idx ON rankalpha.fact_screener_rank_2027_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2027_12_source_key_idx ON rankalpha.fact_screener_rank_2027_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2027_12_stock_key_idx ON rankalpha.fact_screener_rank_2027_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2027_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2027_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2027_12_style_key_idx ON rankalpha.fact_screener_rank_2027_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_01_date_key_idx ON rankalpha.fact_screener_rank_2028_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_01_pkey ON rankalpha.fact_screener_rank_2028_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_01_screening_runid_idx ON rankalpha.fact_screener_rank_2028_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_01_source_key_idx ON rankalpha.fact_screener_rank_2028_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_01_stock_key_idx ON rankalpha.fact_screener_rank_2028_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_01_style_key_idx ON rankalpha.fact_screener_rank_2028_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_02_date_key_idx ON rankalpha.fact_screener_rank_2028_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_02_pkey ON rankalpha.fact_screener_rank_2028_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_02_screening_runid_idx ON rankalpha.fact_screener_rank_2028_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_02_source_key_idx ON rankalpha.fact_screener_rank_2028_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_02_stock_key_idx ON rankalpha.fact_screener_rank_2028_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_02_style_key_idx ON rankalpha.fact_screener_rank_2028_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_03_date_key_idx ON rankalpha.fact_screener_rank_2028_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_03_pkey ON rankalpha.fact_screener_rank_2028_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_03_screening_runid_idx ON rankalpha.fact_screener_rank_2028_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_03_source_key_idx ON rankalpha.fact_screener_rank_2028_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_03_stock_key_idx ON rankalpha.fact_screener_rank_2028_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_03_style_key_idx ON rankalpha.fact_screener_rank_2028_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_04_date_key_idx ON rankalpha.fact_screener_rank_2028_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_04_pkey ON rankalpha.fact_screener_rank_2028_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_04_screening_runid_idx ON rankalpha.fact_screener_rank_2028_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_04_source_key_idx ON rankalpha.fact_screener_rank_2028_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_04_stock_key_idx ON rankalpha.fact_screener_rank_2028_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_04_style_key_idx ON rankalpha.fact_screener_rank_2028_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_05_date_key_idx ON rankalpha.fact_screener_rank_2028_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_05_pkey ON rankalpha.fact_screener_rank_2028_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_05_screening_runid_idx ON rankalpha.fact_screener_rank_2028_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_05_source_key_idx ON rankalpha.fact_screener_rank_2028_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_05_stock_key_idx ON rankalpha.fact_screener_rank_2028_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_05_style_key_idx ON rankalpha.fact_screener_rank_2028_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_06_date_key_idx ON rankalpha.fact_screener_rank_2028_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_06_pkey ON rankalpha.fact_screener_rank_2028_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_06_screening_runid_idx ON rankalpha.fact_screener_rank_2028_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_06_source_key_idx ON rankalpha.fact_screener_rank_2028_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_06_stock_key_idx ON rankalpha.fact_screener_rank_2028_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_06_style_key_idx ON rankalpha.fact_screener_rank_2028_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_07_date_key_idx ON rankalpha.fact_screener_rank_2028_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_07_pkey ON rankalpha.fact_screener_rank_2028_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_07_screening_runid_idx ON rankalpha.fact_screener_rank_2028_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_07_source_key_idx ON rankalpha.fact_screener_rank_2028_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_07_stock_key_idx ON rankalpha.fact_screener_rank_2028_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_07_style_key_idx ON rankalpha.fact_screener_rank_2028_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_08_date_key_idx ON rankalpha.fact_screener_rank_2028_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_08_pkey ON rankalpha.fact_screener_rank_2028_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_08_screening_runid_idx ON rankalpha.fact_screener_rank_2028_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_08_source_key_idx ON rankalpha.fact_screener_rank_2028_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_08_stock_key_idx ON rankalpha.fact_screener_rank_2028_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_08_style_key_idx ON rankalpha.fact_screener_rank_2028_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_09_date_key_idx ON rankalpha.fact_screener_rank_2028_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_09_pkey ON rankalpha.fact_screener_rank_2028_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_09_screening_runid_idx ON rankalpha.fact_screener_rank_2028_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_09_source_key_idx ON rankalpha.fact_screener_rank_2028_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_09_stock_key_idx ON rankalpha.fact_screener_rank_2028_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_09_style_key_idx ON rankalpha.fact_screener_rank_2028_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_10_date_key_idx ON rankalpha.fact_screener_rank_2028_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_10_pkey ON rankalpha.fact_screener_rank_2028_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_10_screening_runid_idx ON rankalpha.fact_screener_rank_2028_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_10_source_key_idx ON rankalpha.fact_screener_rank_2028_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_10_stock_key_idx ON rankalpha.fact_screener_rank_2028_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_10_style_key_idx ON rankalpha.fact_screener_rank_2028_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_11_date_key_idx ON rankalpha.fact_screener_rank_2028_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_11_pkey ON rankalpha.fact_screener_rank_2028_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_11_screening_runid_idx ON rankalpha.fact_screener_rank_2028_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_11_source_key_idx ON rankalpha.fact_screener_rank_2028_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_11_stock_key_idx ON rankalpha.fact_screener_rank_2028_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_11_style_key_idx ON rankalpha.fact_screener_rank_2028_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2028_12_date_key_idx ON rankalpha.fact_screener_rank_2028_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2028_12_pkey ON rankalpha.fact_screener_rank_2028_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2028_12_screening_runid_idx ON rankalpha.fact_screener_rank_2028_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2028_12_source_key_idx ON rankalpha.fact_screener_rank_2028_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2028_12_stock_key_idx ON rankalpha.fact_screener_rank_2028_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2028_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2028_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2028_12_style_key_idx ON rankalpha.fact_screener_rank_2028_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_01_date_key_idx ON rankalpha.fact_screener_rank_2029_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_01_pkey ON rankalpha.fact_screener_rank_2029_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_01_screening_runid_idx ON rankalpha.fact_screener_rank_2029_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_01_source_key_idx ON rankalpha.fact_screener_rank_2029_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_01_stock_key_idx ON rankalpha.fact_screener_rank_2029_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_01_style_key_idx ON rankalpha.fact_screener_rank_2029_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_02_date_key_idx ON rankalpha.fact_screener_rank_2029_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_02_pkey ON rankalpha.fact_screener_rank_2029_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_02_screening_runid_idx ON rankalpha.fact_screener_rank_2029_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_02_source_key_idx ON rankalpha.fact_screener_rank_2029_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_02_stock_key_idx ON rankalpha.fact_screener_rank_2029_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_02_style_key_idx ON rankalpha.fact_screener_rank_2029_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_03_date_key_idx ON rankalpha.fact_screener_rank_2029_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_03_pkey ON rankalpha.fact_screener_rank_2029_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_03_screening_runid_idx ON rankalpha.fact_screener_rank_2029_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_03_source_key_idx ON rankalpha.fact_screener_rank_2029_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_03_stock_key_idx ON rankalpha.fact_screener_rank_2029_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_03_style_key_idx ON rankalpha.fact_screener_rank_2029_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_04_date_key_idx ON rankalpha.fact_screener_rank_2029_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_04_pkey ON rankalpha.fact_screener_rank_2029_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_04_screening_runid_idx ON rankalpha.fact_screener_rank_2029_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_04_source_key_idx ON rankalpha.fact_screener_rank_2029_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_04_stock_key_idx ON rankalpha.fact_screener_rank_2029_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_04_style_key_idx ON rankalpha.fact_screener_rank_2029_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_05_date_key_idx ON rankalpha.fact_screener_rank_2029_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_05_pkey ON rankalpha.fact_screener_rank_2029_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_05_screening_runid_idx ON rankalpha.fact_screener_rank_2029_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_05_source_key_idx ON rankalpha.fact_screener_rank_2029_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_05_stock_key_idx ON rankalpha.fact_screener_rank_2029_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_05_style_key_idx ON rankalpha.fact_screener_rank_2029_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_06_date_key_idx ON rankalpha.fact_screener_rank_2029_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_06_pkey ON rankalpha.fact_screener_rank_2029_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_06_screening_runid_idx ON rankalpha.fact_screener_rank_2029_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_06_source_key_idx ON rankalpha.fact_screener_rank_2029_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_06_stock_key_idx ON rankalpha.fact_screener_rank_2029_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_06_style_key_idx ON rankalpha.fact_screener_rank_2029_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_07_date_key_idx ON rankalpha.fact_screener_rank_2029_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_07_pkey ON rankalpha.fact_screener_rank_2029_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_07_screening_runid_idx ON rankalpha.fact_screener_rank_2029_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_07_source_key_idx ON rankalpha.fact_screener_rank_2029_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_07_stock_key_idx ON rankalpha.fact_screener_rank_2029_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_07_style_key_idx ON rankalpha.fact_screener_rank_2029_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_08_date_key_idx ON rankalpha.fact_screener_rank_2029_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_08_pkey ON rankalpha.fact_screener_rank_2029_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_08_screening_runid_idx ON rankalpha.fact_screener_rank_2029_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_08_source_key_idx ON rankalpha.fact_screener_rank_2029_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_08_stock_key_idx ON rankalpha.fact_screener_rank_2029_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_08_style_key_idx ON rankalpha.fact_screener_rank_2029_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_09_date_key_idx ON rankalpha.fact_screener_rank_2029_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_09_pkey ON rankalpha.fact_screener_rank_2029_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_09_screening_runid_idx ON rankalpha.fact_screener_rank_2029_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_09_source_key_idx ON rankalpha.fact_screener_rank_2029_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_09_stock_key_idx ON rankalpha.fact_screener_rank_2029_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_09_style_key_idx ON rankalpha.fact_screener_rank_2029_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_10_date_key_idx ON rankalpha.fact_screener_rank_2029_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_10_pkey ON rankalpha.fact_screener_rank_2029_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_10_screening_runid_idx ON rankalpha.fact_screener_rank_2029_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_10_source_key_idx ON rankalpha.fact_screener_rank_2029_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_10_stock_key_idx ON rankalpha.fact_screener_rank_2029_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_10_style_key_idx ON rankalpha.fact_screener_rank_2029_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_11_date_key_idx ON rankalpha.fact_screener_rank_2029_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_11_pkey ON rankalpha.fact_screener_rank_2029_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_11_screening_runid_idx ON rankalpha.fact_screener_rank_2029_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_11_source_key_idx ON rankalpha.fact_screener_rank_2029_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_11_stock_key_idx ON rankalpha.fact_screener_rank_2029_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_11_style_key_idx ON rankalpha.fact_screener_rank_2029_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2029_12_date_key_idx ON rankalpha.fact_screener_rank_2029_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2029_12_pkey ON rankalpha.fact_screener_rank_2029_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2029_12_screening_runid_idx ON rankalpha.fact_screener_rank_2029_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2029_12_source_key_idx ON rankalpha.fact_screener_rank_2029_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2029_12_stock_key_idx ON rankalpha.fact_screener_rank_2029_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2029_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2029_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2029_12_style_key_idx ON rankalpha.fact_screener_rank_2029_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_01_date_key_idx ON rankalpha.fact_screener_rank_2030_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_01_pkey ON rankalpha.fact_screener_rank_2030_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_01_screening_runid_idx ON rankalpha.fact_screener_rank_2030_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_01_source_key_idx ON rankalpha.fact_screener_rank_2030_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_01_stock_key_idx ON rankalpha.fact_screener_rank_2030_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_01_style_key_idx ON rankalpha.fact_screener_rank_2030_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_02_date_key_idx ON rankalpha.fact_screener_rank_2030_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_02_pkey ON rankalpha.fact_screener_rank_2030_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_02_screening_runid_idx ON rankalpha.fact_screener_rank_2030_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_02_source_key_idx ON rankalpha.fact_screener_rank_2030_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_02_stock_key_idx ON rankalpha.fact_screener_rank_2030_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_02_style_key_idx ON rankalpha.fact_screener_rank_2030_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_03_date_key_idx ON rankalpha.fact_screener_rank_2030_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_03_pkey ON rankalpha.fact_screener_rank_2030_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_03_screening_runid_idx ON rankalpha.fact_screener_rank_2030_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_03_source_key_idx ON rankalpha.fact_screener_rank_2030_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_03_stock_key_idx ON rankalpha.fact_screener_rank_2030_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_03_style_key_idx ON rankalpha.fact_screener_rank_2030_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_04_date_key_idx ON rankalpha.fact_screener_rank_2030_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_04_pkey ON rankalpha.fact_screener_rank_2030_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_04_screening_runid_idx ON rankalpha.fact_screener_rank_2030_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_04_source_key_idx ON rankalpha.fact_screener_rank_2030_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_04_stock_key_idx ON rankalpha.fact_screener_rank_2030_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_04_style_key_idx ON rankalpha.fact_screener_rank_2030_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_05_date_key_idx ON rankalpha.fact_screener_rank_2030_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_05_pkey ON rankalpha.fact_screener_rank_2030_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_05_screening_runid_idx ON rankalpha.fact_screener_rank_2030_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_05_source_key_idx ON rankalpha.fact_screener_rank_2030_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_05_stock_key_idx ON rankalpha.fact_screener_rank_2030_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_05_style_key_idx ON rankalpha.fact_screener_rank_2030_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_06_date_key_idx ON rankalpha.fact_screener_rank_2030_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_06_pkey ON rankalpha.fact_screener_rank_2030_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_06_screening_runid_idx ON rankalpha.fact_screener_rank_2030_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_06_source_key_idx ON rankalpha.fact_screener_rank_2030_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_06_stock_key_idx ON rankalpha.fact_screener_rank_2030_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_06_style_key_idx ON rankalpha.fact_screener_rank_2030_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_07_date_key_idx ON rankalpha.fact_screener_rank_2030_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_07_pkey ON rankalpha.fact_screener_rank_2030_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_07_screening_runid_idx ON rankalpha.fact_screener_rank_2030_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_07_source_key_idx ON rankalpha.fact_screener_rank_2030_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_07_stock_key_idx ON rankalpha.fact_screener_rank_2030_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_07_style_key_idx ON rankalpha.fact_screener_rank_2030_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_08_date_key_idx ON rankalpha.fact_screener_rank_2030_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_08_pkey ON rankalpha.fact_screener_rank_2030_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_08_screening_runid_idx ON rankalpha.fact_screener_rank_2030_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_08_source_key_idx ON rankalpha.fact_screener_rank_2030_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_08_stock_key_idx ON rankalpha.fact_screener_rank_2030_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_08_style_key_idx ON rankalpha.fact_screener_rank_2030_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_09_date_key_idx ON rankalpha.fact_screener_rank_2030_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_09_pkey ON rankalpha.fact_screener_rank_2030_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_09_screening_runid_idx ON rankalpha.fact_screener_rank_2030_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_09_source_key_idx ON rankalpha.fact_screener_rank_2030_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_09_stock_key_idx ON rankalpha.fact_screener_rank_2030_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_09_style_key_idx ON rankalpha.fact_screener_rank_2030_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_10_date_key_idx ON rankalpha.fact_screener_rank_2030_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_10_pkey ON rankalpha.fact_screener_rank_2030_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_10_screening_runid_idx ON rankalpha.fact_screener_rank_2030_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_10_source_key_idx ON rankalpha.fact_screener_rank_2030_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_10_stock_key_idx ON rankalpha.fact_screener_rank_2030_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_10_style_key_idx ON rankalpha.fact_screener_rank_2030_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_11_date_key_idx ON rankalpha.fact_screener_rank_2030_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_11_pkey ON rankalpha.fact_screener_rank_2030_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_11_screening_runid_idx ON rankalpha.fact_screener_rank_2030_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_11_source_key_idx ON rankalpha.fact_screener_rank_2030_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_11_stock_key_idx ON rankalpha.fact_screener_rank_2030_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_11_style_key_idx ON rankalpha.fact_screener_rank_2030_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2030_12_date_key_idx ON rankalpha.fact_screener_rank_2030_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2030_12_pkey ON rankalpha.fact_screener_rank_2030_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2030_12_screening_runid_idx ON rankalpha.fact_screener_rank_2030_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2030_12_source_key_idx ON rankalpha.fact_screener_rank_2030_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2030_12_stock_key_idx ON rankalpha.fact_screener_rank_2030_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2030_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2030_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2030_12_style_key_idx ON rankalpha.fact_screener_rank_2030_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_01_date_key_idx ON rankalpha.fact_screener_rank_2031_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_01_pkey ON rankalpha.fact_screener_rank_2031_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_01_screening_runid_idx ON rankalpha.fact_screener_rank_2031_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_01_source_key_idx ON rankalpha.fact_screener_rank_2031_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_01_stock_key_idx ON rankalpha.fact_screener_rank_2031_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_01_style_key_idx ON rankalpha.fact_screener_rank_2031_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_02_date_key_idx ON rankalpha.fact_screener_rank_2031_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_02_pkey ON rankalpha.fact_screener_rank_2031_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_02_screening_runid_idx ON rankalpha.fact_screener_rank_2031_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_02_source_key_idx ON rankalpha.fact_screener_rank_2031_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_02_stock_key_idx ON rankalpha.fact_screener_rank_2031_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_02_style_key_idx ON rankalpha.fact_screener_rank_2031_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_03_date_key_idx ON rankalpha.fact_screener_rank_2031_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_03_pkey ON rankalpha.fact_screener_rank_2031_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_03_screening_runid_idx ON rankalpha.fact_screener_rank_2031_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_03_source_key_idx ON rankalpha.fact_screener_rank_2031_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_03_stock_key_idx ON rankalpha.fact_screener_rank_2031_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_03_style_key_idx ON rankalpha.fact_screener_rank_2031_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_04_date_key_idx ON rankalpha.fact_screener_rank_2031_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_04_pkey ON rankalpha.fact_screener_rank_2031_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_04_screening_runid_idx ON rankalpha.fact_screener_rank_2031_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_04_source_key_idx ON rankalpha.fact_screener_rank_2031_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_04_stock_key_idx ON rankalpha.fact_screener_rank_2031_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_04_style_key_idx ON rankalpha.fact_screener_rank_2031_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_05_date_key_idx ON rankalpha.fact_screener_rank_2031_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_05_pkey ON rankalpha.fact_screener_rank_2031_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_05_screening_runid_idx ON rankalpha.fact_screener_rank_2031_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_05_source_key_idx ON rankalpha.fact_screener_rank_2031_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_05_stock_key_idx ON rankalpha.fact_screener_rank_2031_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_05_style_key_idx ON rankalpha.fact_screener_rank_2031_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_06_date_key_idx ON rankalpha.fact_screener_rank_2031_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_06_pkey ON rankalpha.fact_screener_rank_2031_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_06_screening_runid_idx ON rankalpha.fact_screener_rank_2031_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_06_source_key_idx ON rankalpha.fact_screener_rank_2031_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_06_stock_key_idx ON rankalpha.fact_screener_rank_2031_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_06_style_key_idx ON rankalpha.fact_screener_rank_2031_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_07_date_key_idx ON rankalpha.fact_screener_rank_2031_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_07_pkey ON rankalpha.fact_screener_rank_2031_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_07_screening_runid_idx ON rankalpha.fact_screener_rank_2031_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_07_source_key_idx ON rankalpha.fact_screener_rank_2031_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_07_stock_key_idx ON rankalpha.fact_screener_rank_2031_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_07_style_key_idx ON rankalpha.fact_screener_rank_2031_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_08_date_key_idx ON rankalpha.fact_screener_rank_2031_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_08_pkey ON rankalpha.fact_screener_rank_2031_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_08_screening_runid_idx ON rankalpha.fact_screener_rank_2031_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_08_source_key_idx ON rankalpha.fact_screener_rank_2031_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_08_stock_key_idx ON rankalpha.fact_screener_rank_2031_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_08_style_key_idx ON rankalpha.fact_screener_rank_2031_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_09_date_key_idx ON rankalpha.fact_screener_rank_2031_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_09_pkey ON rankalpha.fact_screener_rank_2031_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_09_screening_runid_idx ON rankalpha.fact_screener_rank_2031_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_09_source_key_idx ON rankalpha.fact_screener_rank_2031_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_09_stock_key_idx ON rankalpha.fact_screener_rank_2031_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_09_style_key_idx ON rankalpha.fact_screener_rank_2031_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_10_date_key_idx ON rankalpha.fact_screener_rank_2031_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_10_pkey ON rankalpha.fact_screener_rank_2031_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_10_screening_runid_idx ON rankalpha.fact_screener_rank_2031_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_10_source_key_idx ON rankalpha.fact_screener_rank_2031_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_10_stock_key_idx ON rankalpha.fact_screener_rank_2031_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_10_style_key_idx ON rankalpha.fact_screener_rank_2031_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_11_date_key_idx ON rankalpha.fact_screener_rank_2031_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_11_pkey ON rankalpha.fact_screener_rank_2031_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_11_screening_runid_idx ON rankalpha.fact_screener_rank_2031_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_11_source_key_idx ON rankalpha.fact_screener_rank_2031_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_11_stock_key_idx ON rankalpha.fact_screener_rank_2031_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_11_style_key_idx ON rankalpha.fact_screener_rank_2031_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2031_12_date_key_idx ON rankalpha.fact_screener_rank_2031_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2031_12_pkey ON rankalpha.fact_screener_rank_2031_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2031_12_screening_runid_idx ON rankalpha.fact_screener_rank_2031_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2031_12_source_key_idx ON rankalpha.fact_screener_rank_2031_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2031_12_stock_key_idx ON rankalpha.fact_screener_rank_2031_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2031_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2031_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2031_12_style_key_idx ON rankalpha.fact_screener_rank_2031_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_01_date_key_idx ON rankalpha.fact_screener_rank_2032_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_01_pkey ON rankalpha.fact_screener_rank_2032_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_01_screening_runid_idx ON rankalpha.fact_screener_rank_2032_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_01_source_key_idx ON rankalpha.fact_screener_rank_2032_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_01_stock_key_idx ON rankalpha.fact_screener_rank_2032_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_01_style_key_idx ON rankalpha.fact_screener_rank_2032_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_02_date_key_idx ON rankalpha.fact_screener_rank_2032_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_02_pkey ON rankalpha.fact_screener_rank_2032_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_02_screening_runid_idx ON rankalpha.fact_screener_rank_2032_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_02_source_key_idx ON rankalpha.fact_screener_rank_2032_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_02_stock_key_idx ON rankalpha.fact_screener_rank_2032_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_02_style_key_idx ON rankalpha.fact_screener_rank_2032_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_03_date_key_idx ON rankalpha.fact_screener_rank_2032_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_03_pkey ON rankalpha.fact_screener_rank_2032_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_03_screening_runid_idx ON rankalpha.fact_screener_rank_2032_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_03_source_key_idx ON rankalpha.fact_screener_rank_2032_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_03_stock_key_idx ON rankalpha.fact_screener_rank_2032_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_03_style_key_idx ON rankalpha.fact_screener_rank_2032_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_04_date_key_idx ON rankalpha.fact_screener_rank_2032_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_04_pkey ON rankalpha.fact_screener_rank_2032_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_04_screening_runid_idx ON rankalpha.fact_screener_rank_2032_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_04_source_key_idx ON rankalpha.fact_screener_rank_2032_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_04_stock_key_idx ON rankalpha.fact_screener_rank_2032_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_04_style_key_idx ON rankalpha.fact_screener_rank_2032_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_05_date_key_idx ON rankalpha.fact_screener_rank_2032_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_05_pkey ON rankalpha.fact_screener_rank_2032_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_05_screening_runid_idx ON rankalpha.fact_screener_rank_2032_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_05_source_key_idx ON rankalpha.fact_screener_rank_2032_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_05_stock_key_idx ON rankalpha.fact_screener_rank_2032_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_05_style_key_idx ON rankalpha.fact_screener_rank_2032_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_06_date_key_idx ON rankalpha.fact_screener_rank_2032_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_06_pkey ON rankalpha.fact_screener_rank_2032_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_06_screening_runid_idx ON rankalpha.fact_screener_rank_2032_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_06_source_key_idx ON rankalpha.fact_screener_rank_2032_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_06_stock_key_idx ON rankalpha.fact_screener_rank_2032_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_06_style_key_idx ON rankalpha.fact_screener_rank_2032_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_07_date_key_idx ON rankalpha.fact_screener_rank_2032_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_07_pkey ON rankalpha.fact_screener_rank_2032_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_07_screening_runid_idx ON rankalpha.fact_screener_rank_2032_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_07_source_key_idx ON rankalpha.fact_screener_rank_2032_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_07_stock_key_idx ON rankalpha.fact_screener_rank_2032_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_07_style_key_idx ON rankalpha.fact_screener_rank_2032_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_08_date_key_idx ON rankalpha.fact_screener_rank_2032_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_08_pkey ON rankalpha.fact_screener_rank_2032_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_08_screening_runid_idx ON rankalpha.fact_screener_rank_2032_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_08_source_key_idx ON rankalpha.fact_screener_rank_2032_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_08_stock_key_idx ON rankalpha.fact_screener_rank_2032_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_08_style_key_idx ON rankalpha.fact_screener_rank_2032_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_09_date_key_idx ON rankalpha.fact_screener_rank_2032_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_09_pkey ON rankalpha.fact_screener_rank_2032_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_09_screening_runid_idx ON rankalpha.fact_screener_rank_2032_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_09_source_key_idx ON rankalpha.fact_screener_rank_2032_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_09_stock_key_idx ON rankalpha.fact_screener_rank_2032_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_09_style_key_idx ON rankalpha.fact_screener_rank_2032_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_10_date_key_idx ON rankalpha.fact_screener_rank_2032_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_10_pkey ON rankalpha.fact_screener_rank_2032_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_10_screening_runid_idx ON rankalpha.fact_screener_rank_2032_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_10_source_key_idx ON rankalpha.fact_screener_rank_2032_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_10_stock_key_idx ON rankalpha.fact_screener_rank_2032_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_10_style_key_idx ON rankalpha.fact_screener_rank_2032_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_11_date_key_idx ON rankalpha.fact_screener_rank_2032_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_11_pkey ON rankalpha.fact_screener_rank_2032_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_11_screening_runid_idx ON rankalpha.fact_screener_rank_2032_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_11_source_key_idx ON rankalpha.fact_screener_rank_2032_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_11_stock_key_idx ON rankalpha.fact_screener_rank_2032_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_11_style_key_idx ON rankalpha.fact_screener_rank_2032_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2032_12_date_key_idx ON rankalpha.fact_screener_rank_2032_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2032_12_pkey ON rankalpha.fact_screener_rank_2032_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2032_12_screening_runid_idx ON rankalpha.fact_screener_rank_2032_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2032_12_source_key_idx ON rankalpha.fact_screener_rank_2032_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2032_12_stock_key_idx ON rankalpha.fact_screener_rank_2032_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2032_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2032_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2032_12_style_key_idx ON rankalpha.fact_screener_rank_2032_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_01_date_key_idx ON rankalpha.fact_screener_rank_2033_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_01_pkey ON rankalpha.fact_screener_rank_2033_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_01_screening_runid_idx ON rankalpha.fact_screener_rank_2033_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_01_source_key_idx ON rankalpha.fact_screener_rank_2033_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_01_stock_key_idx ON rankalpha.fact_screener_rank_2033_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_01_style_key_idx ON rankalpha.fact_screener_rank_2033_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_02_date_key_idx ON rankalpha.fact_screener_rank_2033_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_02_pkey ON rankalpha.fact_screener_rank_2033_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_02_screening_runid_idx ON rankalpha.fact_screener_rank_2033_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_02_source_key_idx ON rankalpha.fact_screener_rank_2033_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_02_stock_key_idx ON rankalpha.fact_screener_rank_2033_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_02_style_key_idx ON rankalpha.fact_screener_rank_2033_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_03_date_key_idx ON rankalpha.fact_screener_rank_2033_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_03_pkey ON rankalpha.fact_screener_rank_2033_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_03_screening_runid_idx ON rankalpha.fact_screener_rank_2033_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_03_source_key_idx ON rankalpha.fact_screener_rank_2033_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_03_stock_key_idx ON rankalpha.fact_screener_rank_2033_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_03_style_key_idx ON rankalpha.fact_screener_rank_2033_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_04_date_key_idx ON rankalpha.fact_screener_rank_2033_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_04_pkey ON rankalpha.fact_screener_rank_2033_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_04_screening_runid_idx ON rankalpha.fact_screener_rank_2033_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_04_source_key_idx ON rankalpha.fact_screener_rank_2033_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_04_stock_key_idx ON rankalpha.fact_screener_rank_2033_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_04_style_key_idx ON rankalpha.fact_screener_rank_2033_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_05_date_key_idx ON rankalpha.fact_screener_rank_2033_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_05_pkey ON rankalpha.fact_screener_rank_2033_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_05_screening_runid_idx ON rankalpha.fact_screener_rank_2033_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_05_source_key_idx ON rankalpha.fact_screener_rank_2033_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_05_stock_key_idx ON rankalpha.fact_screener_rank_2033_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_05_style_key_idx ON rankalpha.fact_screener_rank_2033_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_06_date_key_idx ON rankalpha.fact_screener_rank_2033_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_06_pkey ON rankalpha.fact_screener_rank_2033_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_06_screening_runid_idx ON rankalpha.fact_screener_rank_2033_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_06_source_key_idx ON rankalpha.fact_screener_rank_2033_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_06_stock_key_idx ON rankalpha.fact_screener_rank_2033_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_06_style_key_idx ON rankalpha.fact_screener_rank_2033_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_07_date_key_idx ON rankalpha.fact_screener_rank_2033_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_07_pkey ON rankalpha.fact_screener_rank_2033_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_07_screening_runid_idx ON rankalpha.fact_screener_rank_2033_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_07_source_key_idx ON rankalpha.fact_screener_rank_2033_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_07_stock_key_idx ON rankalpha.fact_screener_rank_2033_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_07_style_key_idx ON rankalpha.fact_screener_rank_2033_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_08_date_key_idx ON rankalpha.fact_screener_rank_2033_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_08_pkey ON rankalpha.fact_screener_rank_2033_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_08_screening_runid_idx ON rankalpha.fact_screener_rank_2033_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_08_source_key_idx ON rankalpha.fact_screener_rank_2033_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_08_stock_key_idx ON rankalpha.fact_screener_rank_2033_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_08_style_key_idx ON rankalpha.fact_screener_rank_2033_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_09_date_key_idx ON rankalpha.fact_screener_rank_2033_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_09_pkey ON rankalpha.fact_screener_rank_2033_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_09_screening_runid_idx ON rankalpha.fact_screener_rank_2033_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_09_source_key_idx ON rankalpha.fact_screener_rank_2033_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_09_stock_key_idx ON rankalpha.fact_screener_rank_2033_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_09_style_key_idx ON rankalpha.fact_screener_rank_2033_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_10_date_key_idx ON rankalpha.fact_screener_rank_2033_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_10_pkey ON rankalpha.fact_screener_rank_2033_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_10_screening_runid_idx ON rankalpha.fact_screener_rank_2033_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_10_source_key_idx ON rankalpha.fact_screener_rank_2033_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_10_stock_key_idx ON rankalpha.fact_screener_rank_2033_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_10_style_key_idx ON rankalpha.fact_screener_rank_2033_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_11_date_key_idx ON rankalpha.fact_screener_rank_2033_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_11_pkey ON rankalpha.fact_screener_rank_2033_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_11_screening_runid_idx ON rankalpha.fact_screener_rank_2033_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_11_source_key_idx ON rankalpha.fact_screener_rank_2033_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_11_stock_key_idx ON rankalpha.fact_screener_rank_2033_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_11_style_key_idx ON rankalpha.fact_screener_rank_2033_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2033_12_date_key_idx ON rankalpha.fact_screener_rank_2033_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2033_12_pkey ON rankalpha.fact_screener_rank_2033_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2033_12_screening_runid_idx ON rankalpha.fact_screener_rank_2033_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2033_12_source_key_idx ON rankalpha.fact_screener_rank_2033_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2033_12_stock_key_idx ON rankalpha.fact_screener_rank_2033_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2033_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2033_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2033_12_style_key_idx ON rankalpha.fact_screener_rank_2033_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_01_date_key_idx ON rankalpha.fact_screener_rank_2034_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_01_pkey ON rankalpha.fact_screener_rank_2034_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_01_screening_runid_idx ON rankalpha.fact_screener_rank_2034_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_01_source_key_idx ON rankalpha.fact_screener_rank_2034_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_01_stock_key_idx ON rankalpha.fact_screener_rank_2034_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_01_style_key_idx ON rankalpha.fact_screener_rank_2034_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_02_date_key_idx ON rankalpha.fact_screener_rank_2034_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_02_pkey ON rankalpha.fact_screener_rank_2034_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_02_screening_runid_idx ON rankalpha.fact_screener_rank_2034_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_02_source_key_idx ON rankalpha.fact_screener_rank_2034_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_02_stock_key_idx ON rankalpha.fact_screener_rank_2034_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_02_style_key_idx ON rankalpha.fact_screener_rank_2034_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_03_date_key_idx ON rankalpha.fact_screener_rank_2034_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_03_pkey ON rankalpha.fact_screener_rank_2034_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_03_screening_runid_idx ON rankalpha.fact_screener_rank_2034_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_03_source_key_idx ON rankalpha.fact_screener_rank_2034_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_03_stock_key_idx ON rankalpha.fact_screener_rank_2034_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_03_style_key_idx ON rankalpha.fact_screener_rank_2034_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_04_date_key_idx ON rankalpha.fact_screener_rank_2034_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_04_pkey ON rankalpha.fact_screener_rank_2034_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_04_screening_runid_idx ON rankalpha.fact_screener_rank_2034_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_04_source_key_idx ON rankalpha.fact_screener_rank_2034_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_04_stock_key_idx ON rankalpha.fact_screener_rank_2034_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_04_style_key_idx ON rankalpha.fact_screener_rank_2034_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_05_date_key_idx ON rankalpha.fact_screener_rank_2034_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_05_pkey ON rankalpha.fact_screener_rank_2034_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_05_screening_runid_idx ON rankalpha.fact_screener_rank_2034_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_05_source_key_idx ON rankalpha.fact_screener_rank_2034_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_05_stock_key_idx ON rankalpha.fact_screener_rank_2034_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_05_style_key_idx ON rankalpha.fact_screener_rank_2034_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_06_date_key_idx ON rankalpha.fact_screener_rank_2034_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_06_pkey ON rankalpha.fact_screener_rank_2034_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_06_screening_runid_idx ON rankalpha.fact_screener_rank_2034_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_06_source_key_idx ON rankalpha.fact_screener_rank_2034_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_06_stock_key_idx ON rankalpha.fact_screener_rank_2034_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_06_style_key_idx ON rankalpha.fact_screener_rank_2034_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_07_date_key_idx ON rankalpha.fact_screener_rank_2034_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_07_pkey ON rankalpha.fact_screener_rank_2034_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_07_screening_runid_idx ON rankalpha.fact_screener_rank_2034_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_07_source_key_idx ON rankalpha.fact_screener_rank_2034_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_07_stock_key_idx ON rankalpha.fact_screener_rank_2034_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_07_style_key_idx ON rankalpha.fact_screener_rank_2034_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_08_date_key_idx ON rankalpha.fact_screener_rank_2034_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_08_pkey ON rankalpha.fact_screener_rank_2034_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_08_screening_runid_idx ON rankalpha.fact_screener_rank_2034_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_08_source_key_idx ON rankalpha.fact_screener_rank_2034_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_08_stock_key_idx ON rankalpha.fact_screener_rank_2034_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_08_style_key_idx ON rankalpha.fact_screener_rank_2034_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_09_date_key_idx ON rankalpha.fact_screener_rank_2034_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_09_pkey ON rankalpha.fact_screener_rank_2034_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_09_screening_runid_idx ON rankalpha.fact_screener_rank_2034_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_09_source_key_idx ON rankalpha.fact_screener_rank_2034_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_09_stock_key_idx ON rankalpha.fact_screener_rank_2034_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_09_style_key_idx ON rankalpha.fact_screener_rank_2034_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_10_date_key_idx ON rankalpha.fact_screener_rank_2034_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_10_pkey ON rankalpha.fact_screener_rank_2034_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_10_screening_runid_idx ON rankalpha.fact_screener_rank_2034_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_10_source_key_idx ON rankalpha.fact_screener_rank_2034_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_10_stock_key_idx ON rankalpha.fact_screener_rank_2034_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_10_style_key_idx ON rankalpha.fact_screener_rank_2034_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_11_date_key_idx ON rankalpha.fact_screener_rank_2034_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_11_pkey ON rankalpha.fact_screener_rank_2034_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_11_screening_runid_idx ON rankalpha.fact_screener_rank_2034_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_11_source_key_idx ON rankalpha.fact_screener_rank_2034_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_11_stock_key_idx ON rankalpha.fact_screener_rank_2034_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_11_style_key_idx ON rankalpha.fact_screener_rank_2034_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2034_12_date_key_idx ON rankalpha.fact_screener_rank_2034_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2034_12_pkey ON rankalpha.fact_screener_rank_2034_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2034_12_screening_runid_idx ON rankalpha.fact_screener_rank_2034_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2034_12_source_key_idx ON rankalpha.fact_screener_rank_2034_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2034_12_stock_key_idx ON rankalpha.fact_screener_rank_2034_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2034_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2034_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2034_12_style_key_idx ON rankalpha.fact_screener_rank_2034_12 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_01_date_key_idx ON rankalpha.fact_screener_rank_2035_01 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_01_pkey ON rankalpha.fact_screener_rank_2035_01 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_01_screening_runid_idx ON rankalpha.fact_screener_rank_2035_01 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_01_source_key_idx ON rankalpha.fact_screener_rank_2035_01 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_01_stock_key_idx ON rankalpha.fact_screener_rank_2035_01 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_01_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_01 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_01_style_key_idx ON rankalpha.fact_screener_rank_2035_01 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_02_date_key_idx ON rankalpha.fact_screener_rank_2035_02 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_02_pkey ON rankalpha.fact_screener_rank_2035_02 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_02_screening_runid_idx ON rankalpha.fact_screener_rank_2035_02 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_02_source_key_idx ON rankalpha.fact_screener_rank_2035_02 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_02_stock_key_idx ON rankalpha.fact_screener_rank_2035_02 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_02_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_02 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_02_style_key_idx ON rankalpha.fact_screener_rank_2035_02 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_03_date_key_idx ON rankalpha.fact_screener_rank_2035_03 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_03_pkey ON rankalpha.fact_screener_rank_2035_03 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_03_screening_runid_idx ON rankalpha.fact_screener_rank_2035_03 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_03_source_key_idx ON rankalpha.fact_screener_rank_2035_03 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_03_stock_key_idx ON rankalpha.fact_screener_rank_2035_03 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_03_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_03 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_03_style_key_idx ON rankalpha.fact_screener_rank_2035_03 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_04_date_key_idx ON rankalpha.fact_screener_rank_2035_04 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_04_pkey ON rankalpha.fact_screener_rank_2035_04 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_04_screening_runid_idx ON rankalpha.fact_screener_rank_2035_04 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_04_source_key_idx ON rankalpha.fact_screener_rank_2035_04 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_04_stock_key_idx ON rankalpha.fact_screener_rank_2035_04 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_04_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_04 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_04_style_key_idx ON rankalpha.fact_screener_rank_2035_04 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_05_date_key_idx ON rankalpha.fact_screener_rank_2035_05 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_05_pkey ON rankalpha.fact_screener_rank_2035_05 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_05_screening_runid_idx ON rankalpha.fact_screener_rank_2035_05 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_05_source_key_idx ON rankalpha.fact_screener_rank_2035_05 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_05_stock_key_idx ON rankalpha.fact_screener_rank_2035_05 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_05_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_05 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_05_style_key_idx ON rankalpha.fact_screener_rank_2035_05 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_06_date_key_idx ON rankalpha.fact_screener_rank_2035_06 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_06_pkey ON rankalpha.fact_screener_rank_2035_06 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_06_screening_runid_idx ON rankalpha.fact_screener_rank_2035_06 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_06_source_key_idx ON rankalpha.fact_screener_rank_2035_06 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_06_stock_key_idx ON rankalpha.fact_screener_rank_2035_06 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_06_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_06 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_06_style_key_idx ON rankalpha.fact_screener_rank_2035_06 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_07_date_key_idx ON rankalpha.fact_screener_rank_2035_07 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_07_pkey ON rankalpha.fact_screener_rank_2035_07 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_07_screening_runid_idx ON rankalpha.fact_screener_rank_2035_07 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_07_source_key_idx ON rankalpha.fact_screener_rank_2035_07 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_07_stock_key_idx ON rankalpha.fact_screener_rank_2035_07 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_07_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_07 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_07_style_key_idx ON rankalpha.fact_screener_rank_2035_07 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_08_date_key_idx ON rankalpha.fact_screener_rank_2035_08 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_08_pkey ON rankalpha.fact_screener_rank_2035_08 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_08_screening_runid_idx ON rankalpha.fact_screener_rank_2035_08 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_08_source_key_idx ON rankalpha.fact_screener_rank_2035_08 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_08_stock_key_idx ON rankalpha.fact_screener_rank_2035_08 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_08_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_08 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_08_style_key_idx ON rankalpha.fact_screener_rank_2035_08 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_09_date_key_idx ON rankalpha.fact_screener_rank_2035_09 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_09_pkey ON rankalpha.fact_screener_rank_2035_09 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_09_screening_runid_idx ON rankalpha.fact_screener_rank_2035_09 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_09_source_key_idx ON rankalpha.fact_screener_rank_2035_09 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_09_stock_key_idx ON rankalpha.fact_screener_rank_2035_09 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_09_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_09 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_09_style_key_idx ON rankalpha.fact_screener_rank_2035_09 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_10_date_key_idx ON rankalpha.fact_screener_rank_2035_10 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_10_pkey ON rankalpha.fact_screener_rank_2035_10 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_10_screening_runid_idx ON rankalpha.fact_screener_rank_2035_10 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_10_source_key_idx ON rankalpha.fact_screener_rank_2035_10 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_10_stock_key_idx ON rankalpha.fact_screener_rank_2035_10 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_10_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_10 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_10_style_key_idx ON rankalpha.fact_screener_rank_2035_10 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_11_date_key_idx ON rankalpha.fact_screener_rank_2035_11 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_11_pkey ON rankalpha.fact_screener_rank_2035_11 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_11_screening_runid_idx ON rankalpha.fact_screener_rank_2035_11 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_11_source_key_idx ON rankalpha.fact_screener_rank_2035_11 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_11_stock_key_idx ON rankalpha.fact_screener_rank_2035_11 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_11_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_11 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_11_style_key_idx ON rankalpha.fact_screener_rank_2035_11 USING btree (style_key);

CREATE INDEX fact_screener_rank_2035_12_date_key_idx ON rankalpha.fact_screener_rank_2035_12 USING btree (date_key);

CREATE UNIQUE INDEX fact_screener_rank_2035_12_pkey ON rankalpha.fact_screener_rank_2035_12 USING btree (date_key, fact_id);

CREATE INDEX fact_screener_rank_2035_12_screening_runid_idx ON rankalpha.fact_screener_rank_2035_12 USING btree (screening_runid);

CREATE INDEX fact_screener_rank_2035_12_source_key_idx ON rankalpha.fact_screener_rank_2035_12 USING btree (source_key);

CREATE INDEX fact_screener_rank_2035_12_stock_key_idx ON rankalpha.fact_screener_rank_2035_12 USING btree (stock_key);

CREATE INDEX fact_screener_rank_2035_12_stock_key_source_key_style_key_d_idx ON rankalpha.fact_screener_rank_2035_12 USING btree (stock_key, source_key, style_key, date_key);

CREATE INDEX fact_screener_rank_2035_12_style_key_idx ON rankalpha.fact_screener_rank_2035_12 USING btree (style_key);

CREATE UNIQUE INDEX fact_security_price_pkey ON rankalpha.fact_security_price USING btree (date_key, stock_key);

CREATE UNIQUE INDEX fact_borrow_pkey ON rankalpha.fact_stock_borrow_rate USING btree (date_key, stock_key);

CREATE INDEX idx_corr_date ON ONLY rankalpha.fact_stock_correlation USING btree (date_key);

CREATE INDEX idx_corr_pair_date ON ONLY rankalpha.fact_stock_correlation USING btree (stock1_key, stock2_key, date_key);

CREATE UNIQUE INDEX pk_fact_stock_corr ON ONLY rankalpha.fact_stock_correlation USING btree (date_key, fact_id);

CREATE UNIQUE INDEX fact_stock_score_types_pkey ON ONLY rankalpha.fact_stock_score_types USING btree (date_key, fact_id);

CREATE INDEX idx_fact_stock_score_types_score_type_stock ON ONLY rankalpha.fact_stock_score_types USING btree (score_type_key, stock_key);

CREATE UNIQUE INDEX fact_stock_scores_pkey ON ONLY rankalpha.fact_stock_scores USING btree (date_key, fact_id);

CREATE INDEX idx_fact_stock_scores_stock_style ON ONLY rankalpha.fact_stock_scores USING btree (stock_key, style_key);

CREATE UNIQUE INDEX fact_trade_recommendation_pkey ON rankalpha.fact_trade_recommendation USING btree (recommendation_id);

CREATE UNIQUE INDEX uq_trade_rec ON rankalpha.fact_trade_recommendation USING btree (date_key, stock_key, source_key, action);

CREATE UNIQUE INDEX flyway_schema_history_pk ON rankalpha.flyway_schema_history USING btree (installed_rank);

CREATE INDEX flyway_schema_history_s_idx ON rankalpha.flyway_schema_history USING btree (success);

CREATE UNIQUE INDEX portfolio_pkey ON rankalpha.portfolio USING btree (portfolio_id);

CREATE UNIQUE INDEX uq_portfolio_name ON rankalpha.portfolio USING btree (portfolio_name);

CREATE INDEX idx_portpos_portfolio ON rankalpha.portfolio_position USING btree (portfolio_id);

CREATE INDEX idx_portpos_stock ON rankalpha.portfolio_position USING btree (stock_key);

CREATE UNIQUE INDEX portfolio_position_pkey ON rankalpha.portfolio_position USING btree (position_id);

CREATE UNIQUE INDEX uq_portfolio_stock ON rankalpha.portfolio_position USING btree (portfolio_id, stock_key);


-- sequences
-- rankalpha.dim_asset_type_asset_type_key_seq definition

-- DROP SEQUENCE rankalpha.dim_asset_type_asset_type_key_seq;

CREATE SEQUENCE rankalpha.dim_asset_type_asset_type_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_benchmark_benchmark_key_seq definition

-- DROP SEQUENCE rankalpha.dim_benchmark_benchmark_key_seq;

CREATE SEQUENCE rankalpha.dim_benchmark_benchmark_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_confidence_confidence_key_seq definition

-- DROP SEQUENCE rankalpha.dim_confidence_confidence_key_seq;

CREATE SEQUENCE rankalpha.dim_confidence_confidence_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_corr_method_corr_method_key_seq definition

-- DROP SEQUENCE rankalpha.dim_corr_method_corr_method_key_seq;

CREATE SEQUENCE rankalpha.dim_corr_method_corr_method_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_corr_window_corr_window_key_seq definition

-- DROP SEQUENCE rankalpha.dim_corr_window_corr_window_key_seq;

CREATE SEQUENCE rankalpha.dim_corr_window_corr_window_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_factor_factor_key_seq definition

-- DROP SEQUENCE rankalpha.dim_factor_factor_key_seq;

CREATE SEQUENCE rankalpha.dim_factor_factor_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_fin_metric_metric_key_seq definition

-- DROP SEQUENCE rankalpha.dim_fin_metric_metric_key_seq;

CREATE SEQUENCE rankalpha.dim_fin_metric_metric_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_rating_rating_key_seq definition

-- DROP SEQUENCE rankalpha.dim_rating_rating_key_seq;

CREATE SEQUENCE rankalpha.dim_rating_rating_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_score_type_score_type_key_seq definition

-- DROP SEQUENCE rankalpha.dim_score_type_score_type_key_seq;

CREATE SEQUENCE rankalpha.dim_score_type_score_type_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_source_source_key_seq definition

-- DROP SEQUENCE rankalpha.dim_source_source_key_seq;

CREATE SEQUENCE rankalpha.dim_source_source_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_stock_stock_key_seq definition

-- DROP SEQUENCE rankalpha.dim_stock_stock_key_seq;

CREATE SEQUENCE rankalpha.dim_stock_stock_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_stress_scenario_scenario_key_seq definition

-- DROP SEQUENCE rankalpha.dim_stress_scenario_scenario_key_seq;

CREATE SEQUENCE rankalpha.dim_stress_scenario_scenario_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_style_style_key_seq definition

-- DROP SEQUENCE rankalpha.dim_style_style_key_seq;

CREATE SEQUENCE rankalpha.dim_style_style_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_tenor_tenor_key_seq definition

-- DROP SEQUENCE rankalpha.dim_tenor_tenor_key_seq;

CREATE SEQUENCE rankalpha.dim_tenor_tenor_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_timeframe_timeframe_key_seq definition

-- DROP SEQUENCE rankalpha.dim_timeframe_timeframe_key_seq;

CREATE SEQUENCE rankalpha.dim_timeframe_timeframe_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_trend_category_trend_key_seq definition

-- DROP SEQUENCE rankalpha.dim_trend_category_trend_key_seq;

CREATE SEQUENCE rankalpha.dim_trend_category_trend_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;


-- rankalpha.dim_var_method_var_method_key_seq definition

-- DROP SEQUENCE rankalpha.dim_var_method_var_method_key_seq;

CREATE SEQUENCE rankalpha.dim_var_method_var_method_key_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;