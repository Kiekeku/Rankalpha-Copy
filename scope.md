## Why demand still exists (even in a crowded market)

- **Retail‑investor tools are ballooning**  
  The trading/investing app market is expected to jump from ≈ $53 B in 2024 to $64 B in 2025 (20 % YoY).

- **DIY research budgets are growing**  
  Hedge funds plan to increase spending on alternative data in 2025; 95 % of buyers expect bigger or equal budgets. Retail follows the same arc (cheaper data, same FOMO).

- **Mass‑market user growth hasn’t stalled**  
  Robinhood just logged 25.5 M funded customers (all‑time high, up 2 M YoY). People still want rankings, dashboards, and “what should I buy today?” answers.

- **ETF culture ≠ fad**  
  Europe’s ETF savings‑plan craze grew 33 % last year; younger investors love simple, rules‑based funnels—exactly the kind of audience that’ll pay for a ranking feed.

- **Niche research software is still small**  
  “Pure” investment‑research platforms were only a $2.5 B slice in 2024—tiny versus Bloomberg’s $30 k terminals. Room for specialists.

> **Translation:**  
> The pie is expanding, and individual investors keep paying for curated, opinionated shortcuts. Your site can absolutely find subscribers—if you give them something existing screens don’t.

---

## Must‑have table stakes (or users bounce in 30 sec)

- **Transparent scoring methodology**  
  Show the exact formula weights or at least the factors (e.g., 50 % 12‑month momentum, 30 % forward EV/EBIT, 20 % NLP sentiment). Hiding the sauce ruins trust.

- **Backtested performance vs. benchmark**  
  “Here’s how our top 10 beat the S&P/TSX since 2015” and a drawdown chart.

- **Realtime or near‑realtime quotes**  
  15‑minute delays are fine for research; swing traders will expect faster.

- **Watchlist + email / push alerts**  
  “Ping me when Momentum > 80 and Sentiment flips positive.”

- **Basic portfolio tracker**  
  Let users see how their actual holdings score.

---

## High‑impact differentiators (where you can win)

| Feature                     | Why it sticks                                                          | Quick build hint                                                        |
|-----------------------------|------------------------------------------------------------------------|--------------------------------------------------------------------------|
| User‑tunable weight sliders | Lets power users override your default ranking—creates stickiness.     | Store weights per account, recalc in real time with Redis‑cached factors. |
| Alt‑data sentiment layer    | Scrape earnings‑call transcripts, Reddit, X; run a transformer model for a unified “buzz” score. | Cohere/SageMaker endpoint + vector DB for embeddings.                    |
| Factor exposure “X‑ray”     | Show how a ticker scores across Value, Quality, Vol, Size. Helps diversification junkies. | Calculate rolling regressions vs. Fama‑French factors weekly.            |
| Regime‑aware momentum       | Momentum behaves differently after Fed hikes vs. cuts. Auto‑adjust lookback windows. | Simple ML classifier on macro regime, feed parameters into momentum calc. |
| Sector rotation heatmap     | Visual, instantly shareable on social.                                 | D3.js or Plotly heatmap, updated daily.                                  |
| Brokerage API push‑trades   | “Send top 3 picks to Interactive Brokers as conditional orders.”       | IBKR REST (you already toyed with IBKR OAuth!).                          |
| Explain‑my‑score GPT widget | One‑click natural language summary: “AAPL ranks #3 because revenue revisions +5 %, MACD > 0, insider buys last 30 d.” | Chunk factors into prompt templates, stream back via OpenAI.            |

---

## Monetisation gameplan

- **Freemium** – Limited tickers, delayed data, no custom weights.  
- **Solo Pro (~$25–$40 / mo)** – Full universe, alerting, backtests.  
- **Power ($80–$120 / mo)** – Alt‑data sentiment, broker integration, API access.  
- **Teams / Advisors (custom)** – Whitelabel dashboards, bulk export, compliance logs.

> **Pro tip:** Resist the urge to price like Bloomberg. You’re in the “coffee‑per‑day” SaaS lane until you’ve proved excess alpha.

---

## Compliance boxes you cannot skip

- **Clear disclaimers:** “Not investment advice”, “Past performance…”.  
- **CSA / SEC marketing rules:** No cherry‑picking; show methodology.  
- **GDPR / PIPEDA:** If you later serve EU clients, cookie consent + data subject rights.  
- **Data vendor terms:** Alpha Vantage okay for redisplay; IEX realtime isn’t.

---

## Tech stack that won’t bite you later

- **Backend:** FastAPI or ASP.NET Core + Postgres (tick data in TimescaleDB).  
- **Data ingest:** Airbyte/Elevio to pull IEX, Tiingo, RavenPack, etc.  
- **Cache / stream:** Redis + Celery for daily runs; WebSockets for pushing live scores.  
- **Frontend:** Next.js + Tailwind + Recharts.  
- **Auth / Billing:** Auth0 + Stripe (metered usage ready for scale).  
- **Infra:** Docker Compose → Kubernetes on Azure.  
- **Analytics / observability:** Grafana + Metabase; OpenTelemetry traces.

---

## Bottom line

If all you offer is “yet another screener,” you’ll drown in Finviz clones. But a transparent, tweakable ranking engine plus narrative explainers is still rare—and valuable enough for a $29–$99 / mo tier.

Build the core (scores + backtested proof). Add user‑tunable knobs, alt‑data insight, and dead‑simple alerts. Give it an opinionated voice, publish weekly “Top 5 Movers” notes, and you’ll capture a slice of that multibillion‑dollar, fast‑growing market.
