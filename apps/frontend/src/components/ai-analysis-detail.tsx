'use client'

import { useQuery } from '@tanstack/react-query'
import { api, AiAnalysisItem } from '@/lib/api'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

export function AiAnalysisDetail({ analysisId }: { analysisId: string }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['ai-analysis-id', analysisId],
    queryFn: () => api.getAiAnalysisById(analysisId),
    enabled: !!analysisId,
  })

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[...Array(5)].map((_, i) => <Skeleton key={i} className="h-28 w-full" />)}
      </div>
    )
  }
  if (error || !data) {
    return <div className="text-destructive">Failed to load analysis</div>
  }
  const it: AiAnalysisItem = data
  const asOf = new Date(it.as_of_date).toLocaleDateString()

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">{it.symbol}</h1>
        <p className="text-muted-foreground">{it.company_name} • {asOf}</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Summary</CardTitle>
          <CardDescription>High-level snapshot</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
            <Field label="Rating" value={it.overall_rating} />
            <Field label="Confidence" value={it.confidence} />
            <Field label="Timeframe" value={it.recommendation_timeframe} />
            <Field label="Asset" value={it.asset_type} />
            <Field label="Source" value={it.source_name} />
            <Field label="Market Cap" value={fmtBillions(it.market_cap_usd)} />
            <Field label="Rev CAGR 3y" value={fmtPct(it.revenue_cagr_3y_pct)} />
            <Field label="Beta S&P" value={fmt(it.beta_sp500)} />
          </div>
          {it.commentary && (
            <div className="mt-4 p-4 bg-muted rounded-md text-sm leading-relaxed">{it.commentary}</div>
          )}
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Valuation</CardTitle>
          </CardHeader>
          <CardContent className="grid grid-cols-2 gap-4 text-sm">
            <Field label="PE (fwd)" value={fmt(it.pe_forward)} />
            <Field label="EV/EBITDA (fwd)" value={fmt(it.ev_ebitda_forward)} />
            <Field label="PE Percentile" value={fmtPct(it.pe_percentile_in_sector)} />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Factor Scores</CardTitle>
          </CardHeader>
          <CardContent className="grid grid-cols-2 gap-4 text-sm">
            <Field label="Value" value={fmt(it.value_score)} />
            <Field label="Quality" value={fmt(it.quality_score)} />
            <Field label="Momentum" value={fmt(it.momentum_score)} />
            <Field label="Low Vol" value={fmt(it.low_vol_score)} />
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Scenarios</CardTitle>
          </CardHeader>
          <CardContent className="grid grid-cols-3 gap-4 text-sm">
            <Field label="Bull PT" value={fmtCurrency(it.bull_price_target)} />
            <Field label="Base PT" value={fmtCurrency(it.base_price_target)} />
            <Field label="Bear PT" value={fmtCurrency(it.bear_price_target)} />
            <Field label="Bull Prob" value={fmtPct(it.bull_probability_pct)} />
            <Field label="Base Prob" value={fmtPct(it.base_probability_pct)} />
            <Field label="Bear Prob" value={fmtPct(it.bear_probability_pct)} />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Sentiment & Exposure</CardTitle>
          </CardHeader>
          <CardContent className="grid grid-cols-2 gap-4 text-sm">
            <Field label="News Sentiment (30d)" value={fmt(it.news_sentiment_30d)} />
            <Field label="Social Sentiment (7d)" value={fmt(it.social_sentiment_7d)} />
            <Field label="Options Skew (30d)" value={fmt(it.options_skew_30d)} />
            <Field label="Short Interest % Float" value={fmtPct(it.short_interest_pct_float)} />
            <Field label="FX Sensitivity" value={it.fx_sensitivity} />
            <Field label="Commodity Exposure" value={it.commodity_exposure} />
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Short-term Catalysts</CardTitle>
            <CardDescription>Next few weeks</CardDescription>
          </CardHeader>
          <CardContent>
            {it.short_catalysts && it.short_catalysts.length > 0 ? (
              <ul className="space-y-3">
                {it.short_catalysts.map((c: any, idx: number) => (
                  <li key={idx} className="p-3 border rounded-md">
                    <div className="font-medium">{c.title}</div>
                    <div className="text-xs text-muted-foreground mb-1">{c.expected_date || 'TBD'}</div>
                    {c.description && <div className="text-sm mb-1">{c.description}</div>}
                    <div className="text-xs text-muted-foreground">
                      Prob {fmtPct(c.probability_pct)} • Move {fmtPct(c.expected_price_move_pct)} • Priced-in {fmtPct(c.priced_in_pct)}
                    </div>
                  </li>
                ))}
              </ul>
            ) : (
              <div className="text-sm text-muted-foreground">No short-term catalysts</div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Long-term Catalysts</CardTitle>
            <CardDescription>Months to a year</CardDescription>
          </CardHeader>
          <CardContent>
            {it.long_catalysts && it.long_catalysts.length > 0 ? (
              <ul className="space-y-3">
                {it.long_catalysts.map((c: any, idx: number) => (
                  <li key={idx} className="p-3 border rounded-md">
                    <div className="font-medium">{c.title}</div>
                    <div className="text-xs text-muted-foreground mb-1">{c.expected_date || 'TBD'}</div>
                    {c.description && <div className="text-sm mb-1">{c.description}</div>}
                    <div className="text-xs text-muted-foreground">
                      Prob {fmtPct(c.probability_pct)} • Move {fmtPct(c.expected_price_move_pct)} • Priced-in {fmtPct(c.priced_in_pct)}
                    </div>
                  </li>
                ))}
              </ul>
            ) : (
              <div className="text-sm text-muted-foreground">No long-term catalysts</div>
            )}
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Risks</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
              <List label="Macro" items={it.macro_risks} />
              <List label="Headline" items={it.headline_risks} />
              <List label="Data Gaps" items={it.data_gaps} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Peers</CardTitle>
          </CardHeader>
          <CardContent>
            {it.peers && it.peers.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-muted-foreground">
                      <th className="py-1 pr-4">Symbol</th>
                      <th className="py-1 pr-4">PE</th>
                      <th className="py-1 pr-4">EV/EBITDA</th>
                      <th className="py-1 pr-4">1Y Return %</th>
                      <th className="py-1 pr-4">Summary</th>
                    </tr>
                  </thead>
                  <tbody>
                    {it.peers.map((p: any, idx: number) => (
                      <tr key={idx} className="border-t">
                        <td className="py-1 pr-4 font-medium">{p.peer_symbol}</td>
                        <td className="py-1 pr-4">{fmt(p.pe_forward)}</td>
                        <td className="py-1 pr-4">{fmt(p.ev_ebitda_forward)}</td>
                        <td className="py-1 pr-4">{fmt(p.return_1y_pct)}</td>
                        <td className="py-1 pr-4">{p.summary || '—'}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <div className="text-sm text-muted-foreground">No peer data</div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

function Field({ label, value }: { label: string, value?: string }) {
  return (
    <div>
      <div className="text-muted-foreground text-xs">{label}</div>
      <div className="font-medium">{value ?? '—'}</div>
    </div>
  )
}

function List({ label, items }: { label: string, items?: string[] }) {
  return (
    <div>
      <div className="text-xs text-muted-foreground mb-1">{label}</div>
      {items && items.length ? (
        <ul className="list-disc pl-5 space-y-1">
          {items.map((t, i) => <li key={i}>{t}</li>)}
        </ul>
      ) : (
        <div className="text-sm text-muted-foreground">None</div>
      )}
    </div>
  )
}

function fmt(n?: number): string | undefined {
  if (n === null || n === undefined) return undefined
  const v = Number(n)
  if (Number.isNaN(v)) return undefined
  return v.toFixed(2)
}

function fmtPct(n?: number): string | undefined {
  if (n === null || n === undefined) return undefined
  return `${Number(n).toFixed(2)}%`
}

function fmtCurrency(n?: number): string | undefined {
  if (n === null || n === undefined) return undefined
  return `$${Number(n).toFixed(2)}`
}

function fmtBillions(n?: number): string | undefined {
  if (n === null || n === undefined) return undefined
  const v = Number(n)
  if (v >= 1e12) return `$${(v/1e12).toFixed(2)}T`
  if (v >= 1e9) return `$${(v/1e9).toFixed(2)}B`
  if (v >= 1e6) return `$${(v/1e6).toFixed(2)}M`
  return `$${v.toFixed(0)}`
}

