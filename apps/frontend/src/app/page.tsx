'use client'

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { ArrowUpIcon, ArrowDownIcon, TrendingUpIcon, ActivityIcon, ChevronLeftIcon, ChevronRightIcon, InfoIcon } from 'lucide-react'
import { api } from '@/lib/api'
import { StockDetailModal } from '@/components/stock-detail-modal'

export default function HomePage() {
  const [selectedStock, setSelectedStock] = useState<string | null>(null)
  const [modalOpen, setModalOpen] = useState(false)
  const [currentPage, setCurrentPage] = useState(1)
  const [selectedSector, setSelectedSector] = useState('')
  const [selectedGrade, setSelectedGrade] = useState('')
  const pageSize = 20

  // Sector list (cached client-side for 1h)
  const { data: sectors } = useQuery({
    queryKey: ['sectors'],
    queryFn: () => api.listSectors(),
    staleTime: 3_600_000,
  })

  // Server-side pagination: fetch exactly one page window
  const { data: grades, isLoading: gradesLoading } = useQuery({
    queryKey: ['grades-overview', currentPage, selectedSector, selectedGrade],
    queryFn: () => api.getStockGrades({
      limit: pageSize,
      skip: (currentPage - 1) * pageSize,
      sort_by: 'grade',
      sort_order: 'desc',
      sector: selectedSector || undefined,
      min_grade: selectedGrade || undefined,
      max_grade: selectedGrade || undefined,
    }),
  })

  // Keep overview KPIs correct without fetching the entire universe.
  // Query total A and F counts via filtered calls; total_count reflects the full filtered size.
  const { data: gradesA } = useQuery({
    queryKey: ['grades-overview-count-A', selectedSector],
    queryFn: () => api.getStockGrades({ limit: 1, skip: 0, min_grade: 'A', max_grade: 'A', sort_by: 'grade', sort_order: 'desc', sector: selectedSector || undefined }),
  })
  const { data: gradesF } = useQuery({
    queryKey: ['grades-overview-count-F', selectedSector],
    queryFn: () => api.getStockGrades({ limit: 1, skip: 0, min_grade: 'F', max_grade: 'F', sort_by: 'grade', sort_order: 'desc', sector: selectedSector || undefined }),
  })

  const { data: pipeline, isLoading: pipelineLoading } = useQuery({
    queryKey: ['pipeline-health'],
    queryFn: () => api.getPipelineHealth(),
  })

  // Count of actually scored stocks (exclude N/A): min_grade=F..A
  const { data: scoredCount } = useQuery({
    queryKey: ['grades-scored-count', selectedSector],
    queryFn: () => api.getStockGrades({
      limit: 1,
      skip: 0,
      min_grade: 'F',
      max_grade: 'A',
      sort_by: 'grade',
      sort_order: 'desc',
      sector: selectedSector || undefined,
    }),
    staleTime: 60_000,
  })

  const handleStockClick = (symbol: string) => {
    setSelectedStock(symbol)
    setModalOpen(true)
  }

  const totalPages = grades ? Math.ceil(grades.total_count / pageSize) : 0
  const currentStocks = grades?.stocks ?? []

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Overview</h1>
        <p className="text-muted-foreground">
          Today's market status and pipeline health
        </p>
      </div>

      {/* Pipeline Status Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pipeline Status</CardTitle>
            <ActivityIcon className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {pipelineLoading ? (
              <Skeleton className="h-8 w-20" />
            ) : (
              <>
                <div className="text-2xl font-bold capitalize">
                  {pipeline?.overall_status || 'Unknown'}
                </div>
                <p className="text-xs text-muted-foreground">
                  Last check: {pipeline?.last_check ? new Date(pipeline.last_check).toLocaleTimeString() : 'N/A'}
                </p>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Stocks Tracked</CardTitle>
            <TrendingUpIcon className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {gradesLoading ? (
              <Skeleton className="h-8 w-20" />
            ) : (
              <>
                <div className="text-2xl font-bold">{scoredCount?.total_count || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Scored stocks
                </p>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              Top Performers (A)
              <InfoIcon
                className="h-4 w-4 text-muted-foreground"
                title="Counts Grade A stocks; respects selected sector filter."
              />
            </CardTitle>
            <ArrowUpIcon className="h-4 w-4 text-gain" />
          </CardHeader>
          <CardContent>
            {gradesLoading ? (
              <Skeleton className="h-8 w-20" />
            ) : (
              <>
                <div className="text-2xl font-bold">{gradesA?.total_count || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Grade A stocks
                </p>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              Underperformers (F)
              <InfoIcon
                className="h-4 w-4 text-muted-foreground"
                title="Counts Grade F stocks; respects selected sector filter."
              />
            </CardTitle>
            <ArrowDownIcon className="h-4 w-4 text-loss" />
          </CardHeader>
          <CardContent>
            {gradesLoading ? (
              <Skeleton className="h-8 w-20" />
            ) : (
              <>
                <div className="text-2xl font-bold">{gradesF?.total_count || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Grade F stocks
                </p>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      {/* All Ranked Stocks */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Stock Rankings</CardTitle>
              <CardDescription>
                All stocks ranked by grade (A-F) based on momentum, value, and sentiment
              </CardDescription>
            </div>
            <div className="flex items-center gap-4">
              <div>
                <label htmlFor="sectorFilterHome" className="block text-xs font-medium text-muted-foreground">Sector</label>
                <select
                  id="sectorFilterHome"
                  value={selectedSector}
                  onChange={(e) => { setSelectedSector(e.target.value); setCurrentPage(1); }}
                  className="h-9 px-3 border rounded-md text-sm"
                >
                  <option value="">All Sectors</option>
                  {(sectors || []).map((s) => (
                    <option key={s} value={s}>{s}</option>
                  ))}
                </select>
              </div>
              <div>
                <label htmlFor="gradeFilterHome" className="block text-xs font-medium text-muted-foreground">Grade</label>
                <select
                  id="gradeFilterHome"
                  value={selectedGrade}
                  onChange={(e) => { setSelectedGrade(e.target.value); setCurrentPage(1); }}
                  className="h-9 px-3 border rounded-md text-sm"
                >
                  <option value="">All Grades</option>
                  <option value="A">A</option>
                  <option value="B">B</option>
                  <option value="C">C</option>
                  <option value="D">D</option>
                  <option value="F">F</option>
                </select>
              </div>
              <div className="text-sm text-muted-foreground">
                Showing {(currentPage - 1) * pageSize + 1}-{Math.min(currentPage * pageSize, grades?.total_count || 0)} of {grades?.total_count || 0} stocks
              </div>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {gradesLoading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} className="h-16 w-full" />
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {currentStocks.map((stock, index) => (
                <button
                  key={stock.symbol}
                  onClick={() => handleStockClick(stock.symbol)}
                  className="w-full flex items-center justify-between p-4 rounded-lg border hover:bg-accent transition-colors text-left"
                >
                  <div className="flex items-center gap-4">
                    <div className="text-sm font-medium text-muted-foreground min-w-[3rem]">
                      #{(currentPage - 1) * pageSize + index + 1}
                    </div>
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="font-semibold">{stock.symbol}</span>
                        <Badge className={getGradeBadgeColor(stock.overall_grade)}>
                          Grade {stock.overall_grade}
                        </Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">
                        {stock.company_name}
                      </p>
                    </div>
                  </div>
                  <div className="text-right space-y-1">
                    <div className="text-sm">
                      <span className="text-muted-foreground">Momentum:</span>{' '}
                      <span className="font-medium">
                        {stock.momentum_score?.toFixed(1) || 'N/A'}
                      </span>
                    </div>
                    <div className="text-sm">
                      <span className="text-muted-foreground">Value:</span>{' '}
                      <span className="font-medium">
                        {stock.value_score?.toFixed(1) || 'N/A'}
                      </span>
                    </div>
                    <div className="text-sm">
                      <span className="text-muted-foreground">Sentiment:</span>{' '}
                      <span className="font-medium">
                        {stock.sentiment_score?.toFixed(1) || 'N/A'}
                      </span>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
          
          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between pt-4">
              <div className="text-sm text-muted-foreground">
                Page {currentPage} of {totalPages}
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                  disabled={currentPage === 1}
                  className="flex items-center gap-1 px-3 py-2 text-sm border rounded-md hover:bg-accent disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <ChevronLeftIcon className="h-4 w-4" />
                  Previous
                </button>
                <button
                  onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                  disabled={currentPage === totalPages}
                  className="flex items-center gap-1 px-3 py-2 text-sm border rounded-md hover:bg-accent disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                  <ChevronRightIcon className="h-4 w-4" />
                </button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Pipeline Components Status */}
      <Card>
        <CardHeader>
          <CardTitle>Pipeline Components</CardTitle>
          <CardDescription>
            Status of data ingestion and processing components
          </CardDescription>
        </CardHeader>
        <CardContent>
          {pipelineLoading ? (
            <div className="space-y-4">
              {[...Array(3)].map((_, i) => (
                <Skeleton key={i} className="h-12 w-full" />
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {pipeline?.components.map((component) => (
                <div
                  key={component.component}
                  className="flex items-center justify-between p-3 rounded-lg border"
                >
                  <div className="flex items-center gap-3">
                    <div className={`h-2 w-2 rounded-full ${getStatusColor(component.status)}`} />
                    <div>
                      <p className="font-medium capitalize">{component.component}</p>
                      <p className="text-sm text-muted-foreground">{component.message}</p>
                    </div>
                  </div>
                  <div className="text-right text-sm">
                    {component.last_run && (
                      <p>Last run: {new Date(component.last_run).toLocaleString()}</p>
                    )}
                    {component.records_processed !== null && (
                      <p className="text-muted-foreground">
                        {component.records_processed} records
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Stock Detail Modal */}
      <StockDetailModal
        symbol={selectedStock}
        open={modalOpen}
        onOpenChange={setModalOpen}
      />
    </div>
  )
}

function getGradeBadgeColor(grade: string) {
  switch (grade) {
    case 'A':
      return 'bg-gain-soft text-gain hover:bg-gain/10'
    case 'B':
      return 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100'
    case 'C':
      return 'bg-amber-50 text-amber-700 hover:bg-amber-100'
    case 'D':
      return 'bg-orange-50 text-orange-700 hover:bg-orange-100'
    case 'F':
      return 'bg-loss-soft text-loss hover:bg-loss/10'
    default:
      return 'bg-neutralsoft text-foreground hover:bg-muted'
  }
}

function getStatusColor(status: string) {
  switch (status) {
    case 'healthy':
      return 'bg-green-500'
    case 'warning':
      return 'bg-yellow-500'
    case 'error':
      return 'bg-red-500'
    default:
      return 'bg-gray-500'
  }
}
