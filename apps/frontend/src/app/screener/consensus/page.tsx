'use client'

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

export default function ScreenerConsensusPage() {
  const [symbol, setSymbol] = useState('')
  const [appearancesMin, setAppearancesMin] = useState(0)
  const [stylesMin, setStylesMin] = useState(0)
  const [page, setPage] = useState(1)
  const pageSize = 25

  const { data, isLoading, refetch } = useQuery({
    queryKey: ['screener-consensus', symbol, appearancesMin, stylesMin, page],
    queryFn: () => api.listScreenerConsensus({
      symbol: symbol || undefined,
      appearances_min: appearancesMin || undefined,
      styles_min: stylesMin || undefined,
      skip: (page - 1) * pageSize,
      limit: pageSize,
    }),
  })

  const items = data?.items || []
  const total = data?.total_count || 0
  const totalPages = Math.max(1, Math.ceil(total / pageSize))

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Screener Consensus</h1>
        <p className="text-muted-foreground">Latest day, aggregated per symbol across styles/sources.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Filters</CardTitle>
          <CardDescription>Use breadth filters to surface high-consensus names</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap items-end gap-3">
            <div className="space-y-1">
              <label className="text-sm font-medium">Symbol</label><br />
              <input
                placeholder="e.g., NVDA"
                value={symbol}
                onChange={(e) => setSymbol(e.target.value.toUpperCase())}
                className="px-3 py-2 border rounded-md text-sm"
              />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-medium">Min Appearances</label><br />
              <input
                type="number"
                min={0}
                value={appearancesMin}
                onChange={(e) => setAppearancesMin(Number(e.target.value) || 0)}
                className="px-3 py-2 border rounded-md text-sm w-28"
              />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-medium">Min Styles</label><br />
              <input
                type="number"
                min={0}
                value={stylesMin}
                onChange={(e) => setStylesMin(Number(e.target.value) || 0)}
                className="px-3 py-2 border rounded-md text-sm w-28"
              />
            </div>
            <button
              className="px-3 py-2 text-sm border rounded-md hover:bg-accent"
              onClick={() => { setPage(1); refetch() }}
            >Apply</button>
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
              <button className="px-3 py-2 border rounded-md hover:bg-accent disabled:opacity-50" disabled={page <= 1} onClick={() => setPage(p => Math.max(1, p - 1))}>Prev</button>
              <span>Page {page} / {totalPages}</span>
              <button className="px-3 py-2 border rounded-md hover:bg-accent disabled:opacity-50" disabled={page >= totalPages} onClick={() => setPage(p => Math.min(totalPages, p + 1))}>Next</button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-3">{[...Array(10)].map((_, i) => <Skeleton key={i} className="h-16 w-full" />)}</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-left text-muted-foreground">
                    <th className="py-2 pr-4">Symbol</th>
                    <th className="py-2 pr-4">Company</th>
                    <th className="py-2 pr-4">Best Rank</th>
                    <th className="py-2 pr-4">Appear</th>
                    <th className="py-2 pr-4">Styles</th>
                    <th className="py-2 pr-4">Sources</th>
                    <th className="py-2 pr-4">Min Style %</th>
                    <th className="py-2 pr-4">Consensus</th>
                    <th className="py-2 pr-4">Primary</th>
                  </tr>
                </thead>
                <tbody>
                  {items.map((row, idx) => (
                    <tr key={idx} className="border-t">
                      <td className="py-2 pr-4 font-semibold">{row.symbol}</td>
                      <td className="py-2 pr-4 max-w-[16rem] truncate" title={row.company_name || ''}>{row.company_name || '—'}</td>
                      <td className="py-2 pr-4">{row.rank_best ?? '—'}</td>
                      <td className="py-2 pr-4">{row.appearances}</td>
                      <td className="py-2 pr-4">{row.styles_distinct}</td>
                      <td className="py-2 pr-4">{row.sources_distinct}</td>
                      <td className="py-2 pr-4">{fmtPct(row.min_style_rank_pct)}</td>
                      <td className="py-2 pr-4 font-medium">{fmt(row.consensus_score)}</td>
                      <td className="py-2 pr-4 text-xs text-muted-foreground">{row.primary_style || '—'} / {row.primary_source || '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

function fmt(n?: number) {
  if (n === null || n === undefined) return '—'
  return Number(n).toFixed(2)
}

function fmtPct(n?: number) {
  if (n === null || n === undefined) return '—'
  return `${(Number(n) * 100).toFixed(1)}%`
}

