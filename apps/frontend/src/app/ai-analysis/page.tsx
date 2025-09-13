'use client'

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import Link from 'next/link'
import { api, AiAnalysisItem } from '@/lib/api'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

export default function AiAnalysisPage() {
  const [symbol, setSymbol] = useState('')
  const [dateFrom, setDateFrom] = useState('')
  const [dateTo, setDateTo] = useState('')
  const [page, setPage] = useState(1)
  const pageSize = 20

  const { data, isLoading, refetch } = useQuery({
    queryKey: ['ai-analysis', symbol, dateFrom, dateTo, page],
    queryFn: () => api.listAiAnalyses({
      symbol: symbol || undefined,
      date_from: dateFrom || undefined,
      date_to: dateTo || undefined,
      skip: (page - 1) * pageSize,
      limit: pageSize,
      sort_order: 'desc',
    }),
  })

  const items = data?.items || []
  const total = data?.total_count || 0
  const totalPages = Math.max(1, Math.ceil(total / pageSize))

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">AI Analysis</h1>
        <p className="text-muted-foreground">Latest AI-generated analyses with catalysts, scenarios, risks, and peers.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Filters</CardTitle>
          <CardDescription>Filter by symbol and date range</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
            <div className="space-y-1">
              <label htmlFor="aiSymbol" className="text-sm font-medium">Symbol</label>
              <input
                id="aiSymbol"
                placeholder="e.g., GOOGL"
                value={symbol}
                onChange={(e) => setSymbol(e.target.value.toUpperCase())}
                className="h-9 w-full px-3 border rounded-md text-sm bg-background"
              />
            </div>
            <div className="space-y-1">
              <label htmlFor="aiFrom" className="text-sm font-medium">From</label>
              <input
                id="aiFrom"
                type="date"
                value={dateFrom}
                onChange={(e) => setDateFrom(e.target.value)}
                className="h-9 w-full px-3 border rounded-md text-sm bg-background"
              />
            </div>
            <div className="space-y-1">
              <label htmlFor="aiTo" className="text-sm font-medium">To</label>
              <input
                id="aiTo"
                type="date"
                value={dateTo}
                onChange={(e) => setDateTo(e.target.value)}
                className="h-9 w-full px-3 border rounded-md text-sm bg-background"
              />
            </div>
            <div className="flex sm:items-end">
              <button
                className="h-9 px-3 w-full md:w-auto text-sm border rounded-md hover:bg-accent"
                onClick={() => { setPage(1); refetch() }}
              >
                Apply
              </button>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Results</CardTitle>
              <CardDescription>
                Showing {(page - 1) * pageSize + 1}-{Math.min(page * pageSize, total)} of {total}
              </CardDescription>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <button
                className="px-3 py-2 border rounded-md hover:bg-accent disabled:opacity-50"
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
              >Prev</button>
              <span>Page {page} / {totalPages}</span>
              <button
                className="px-3 py-2 border rounded-md hover:bg-accent disabled:opacity-50"
                disabled={page >= totalPages}
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              >Next</button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-3">
              {[...Array(6)].map((_, i) => <Skeleton key={i} className="h-24 w-full" />)}
            </div>
          ) : (
            <div className="space-y-3">
              {items.map((it) => (
                <AiRow key={it.analysis_id} item={it} />
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

function AiRow({ item }: { item: AiAnalysisItem }) {
  return (
    <Link href={`/ai-analysis/id/${item.analysis_id}`} className="block w-full p-4 rounded-lg border hover:bg-accent/30 transition-colors">
      <div className="flex items-center justify-between gap-4">
        <div className="min-w-[10rem]">
          <div className="font-semibold text-lg">{item.symbol}</div>
          <div className="text-sm text-muted-foreground">{item.company_name}</div>
          <div className="text-xs text-muted-foreground">{new Date(item.as_of_date).toLocaleDateString()}</div>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-sm">
          <Field label="Rating" value={item.overall_rating || '—'} />
          <Field label="Confidence" value={item.confidence || '—'} />
          <Field label="Value" value={fmt(item.value_score)} />
          <Field label="Momentum" value={fmt(item.momentum_score)} />
          <Field label="Sentiment (30d)" value={fmt(item.news_sentiment_30d)} />
          <Field label="PE (fwd)" value={fmt(item.pe_forward)} />
          <Field label="EV/EBITDA" value={fmt(item.ev_ebitda_forward)} />
          <Field label="Bull PT" value={fmt(item.bull_price_target, '$')} />
        </div>
      </div>
      {item.commentary && (
        <p className="mt-3 text-sm text-muted-foreground line-clamp-2">{item.commentary}</p>
      )}
    </Link>
  )
}

function Field({ label, value }: { label: string, value?: string }) {
  return (
    <div>
      <div className="text-muted-foreground text-xs">{label}</div>
      <div className="font-medium">{value || '—'}</div>
    </div>
  )
}

function fmt(n?: number, prefix = ''): string | undefined {
  if (n === null || n === undefined) return undefined
  const v = typeof n === 'number' ? n : Number(n)
  if (Number.isNaN(v)) return undefined
  return prefix ? `${prefix}${v.toFixed(2)}` : v.toFixed(2)
}
