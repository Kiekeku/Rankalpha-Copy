'use client'

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { ChevronLeftIcon, ChevronRightIcon, FilterIcon } from 'lucide-react'
import { api } from '@/lib/api'

type SortBy = 'grade' | 'momentum' | 'value' | 'sentiment' | 'symbol'
type SortOrder = 'asc' | 'desc'
import { StockDetailModal } from '@/components/stock-detail-modal'

export default function RankingsPage() {
  const [selectedStock, setSelectedStock] = useState<string | null>(null)
  const [modalOpen, setModalOpen] = useState(false)
  const [currentPage, setCurrentPage] = useState(1)
  const [sortBy, setSortBy] = useState<SortBy>('grade')
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc') // Start with best grades first
  const [selectedGrade, setSelectedGrade] = useState<string>('')
  const [selectedSector, setSelectedSector] = useState<string>('')
  
  const pageSize = 25

  // Server-side pagination: fetch exactly one page window respecting filters
  const { data: grades, isLoading: gradesLoading } = useQuery({
    queryKey: ['all-grades', currentPage, sortBy, sortOrder, selectedGrade, selectedSector],
    queryFn: () => api.getStockGrades({
      limit: pageSize,
      skip: (currentPage - 1) * pageSize,
      sort_by: sortBy,
      sort_order: sortOrder,
      min_grade: selectedGrade || undefined,
      max_grade: selectedGrade || undefined,
      sector: selectedSector || undefined,
    }),
  })

  const handleStockClick = (symbol: string) => {
    setSelectedStock(symbol)
    setModalOpen(true)
  }

  const handleSortChange = (newSortBy: SortBy) => {
    if (sortBy === newSortBy) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortBy(newSortBy)
      setSortOrder(newSortBy === 'grade' ? 'desc' : 'desc') // For grades, desc shows A first; for scores, desc shows highest first
    }
    setCurrentPage(1)
  }

  const handleFilterChange = () => {
    setCurrentPage(1)
  }

  // Calculate pagination
  const filteredStocks = grades?.stocks || []
  const totalPages = Math.ceil((grades?.total_count || 0) / pageSize)
  const currentStocks = filteredStocks

  // Proper sector list via API
  const { data: sectors } = useQuery({
    queryKey: ['sectors'],
    queryFn: () => api.listSectors(),
    staleTime: 3_600_000,
  })

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Stock Rankings</h1>
        <p className="text-muted-foreground">
          Complete leaderboard of all stocks ranked by grade, momentum, value, and sentiment
        </p>
      </div>

      {/* Filters and Controls */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FilterIcon className="h-5 w-5" />
            Filters & Sorting
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 items-end">
            {/* Grade Filter */}
            <div className="space-y-2">
              <label htmlFor="gradeFilter" className="block text-sm font-medium">Grade</label>
              <select
                id="gradeFilter"
                value={selectedGrade}
                onChange={(e) => { setSelectedGrade(e.target.value); handleFilterChange(); }}
                className="h-9 w-full md:w-48 px-3 border rounded-md text-sm"
              >
                <option value="">All Grades</option>
                <option value="A">A</option>
                <option value="B">B</option>
                <option value="C">C</option>
                <option value="D">D</option>
                <option value="F">F</option>
              </select>
            </div>

            {/* Sort Controls */}
            <div className="space-y-2">
              <label className="text-sm font-medium">Sort By</label>
              <div className="flex flex-wrap gap-2">
                <button
                  onClick={() => handleSortChange('grade')}
                  className={`h-9 px-3 text-sm border rounded-md transition-colors ${
                    sortBy === 'grade' ? 'bg-primary text-primary-foreground' : 'hover:bg-accent'
                  }`}
                >
                  Grade {sortBy === 'grade' && (sortOrder === 'asc' ? '↑' : '↓')}
                </button>
                <button
                  onClick={() => handleSortChange('momentum')}
                  className={`h-9 px-3 text-sm border rounded-md transition-colors ${
                    sortBy === 'momentum' ? 'bg-primary text-primary-foreground' : 'hover:bg-accent'
                  }`}
                >
                  Momentum {sortBy === 'momentum' && (sortOrder === 'asc' ? '↑' : '↓')}
                </button>
                <button
                  onClick={() => handleSortChange('value')}
                  className={`h-9 px-3 text-sm border rounded-md transition-colors ${
                    sortBy === 'value' ? 'bg-primary text-primary-foreground' : 'hover:bg-accent'
                  }`}
                >
                  Value {sortBy === 'value' && (sortOrder === 'asc' ? '↑' : '↓')}
                </button>
                <button
                  onClick={() => handleSortChange('sentiment')}
                  className={`h-9 px-3 text-sm border rounded-md transition-colors ${
                    sortBy === 'sentiment' ? 'bg-primary text-primary-foreground' : 'hover:bg-accent'
                  }`}
                >
                  Sentiment {sortBy === 'sentiment' && (sortOrder === 'asc' ? '↑' : '↓')}
                </button>
              </div>
            </div>
            
            {/* Sector Filter */}
            <div className="space-y-2">
              <label htmlFor="sectorFilter" className="block text-sm font-medium">Sector</label>
              <select
                id="sectorFilter"
                value={selectedSector}
                onChange={(e) => { setSelectedSector(e.target.value); handleFilterChange(); }}
                className="h-9 w-full md:w-48 px-3 border rounded-md text-sm"
              >
                <option value="">All Sectors</option>
                {(sectors || []).map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
          </div>

          {grades && (
            <div className="mt-4 text-sm text-muted-foreground">
              Showing page {currentPage} of {totalPages} • {grades.total_count} total stocks
            </div>
          )}
        </CardContent>
      </Card>

      {/* Stock Rankings Table */}
      <Card>
        <CardHeader>
          <CardTitle>Rankings</CardTitle>
          <CardDescription>
            Click on any stock to view detailed analysis and charts
          </CardDescription>
        </CardHeader>
        <CardContent>
          {gradesLoading ? (
            <div className="space-y-3">
              {[...Array(pageSize)].map((_, i) => (
                <Skeleton key={i} className="h-20 w-full" />
              ))}
            </div>
          ) : (
            <div className="space-y-2">
              {currentStocks.map((stock, index) => (
                <button
                  key={`${stock.symbol}-${(currentPage - 1) * pageSize + index}`}
                  onClick={() => handleStockClick(stock.symbol)}
                  className="w-full flex items-center justify-between p-4 rounded-lg border hover:bg-accent transition-colors text-left"
                >
                  <div className="flex items-center gap-4 flex-1">
                    <div className="text-sm font-medium text-muted-foreground min-w-[4rem]">
                      #{(currentPage - 1) * pageSize + index + 1}
                    </div>
                    <div className="flex items-center gap-2 min-w-[6rem]">
                      <span className="font-semibold text-lg">{stock.symbol}</span>
                      <Badge className={getGradeBadgeColor(stock.overall_grade)}>
                        {stock.overall_grade}
                      </Badge>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-muted-foreground truncate">
                        {stock.company_name}
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-6 text-sm">
                    <div className="text-center min-w-[4rem]">
                      <div className="text-muted-foreground">Momentum</div>
                      <div className="font-medium">
                        {stock.momentum_score?.toFixed(1) || 'N/A'}
                      </div>
                    </div>
                    <div className="text-center min-w-[4rem]">
                      <div className="text-muted-foreground">Value</div>
                      <div className="font-medium">
                        {stock.value_score?.toFixed(1) || 'N/A'}
                      </div>
                    </div>
                    <div className="text-center min-w-[4rem]">
                      <div className="text-muted-foreground">Sentiment</div>
                      <div className="font-medium">
                        {stock.sentiment_score?.toFixed(1) || 'N/A'}
                      </div>
                    </div>
                    <div className="text-center min-w-[5rem]">
                      <div className="text-muted-foreground">Confidence</div>
                      <div className="font-medium text-xs">
                        {stock.confidence}
                      </div>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
          
          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between pt-6 border-t mt-6">
              <div className="text-sm text-muted-foreground">
                Page {currentPage} of {totalPages} • {filteredStocks.length} total stocks
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setCurrentPage(1)}
                  disabled={currentPage === 1}
                  className="px-3 py-2 text-sm border rounded-md hover:bg-accent disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  First
                </button>
                <button
                  onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                  disabled={currentPage === 1}
                  className="flex items-center gap-1 px-3 py-2 text-sm border rounded-md hover:bg-accent disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <ChevronLeftIcon className="h-4 w-4" />
                  Previous
                </button>
                <span className="px-3 py-2 text-sm border rounded-md bg-accent">
                  {currentPage}
                </span>
                <button
                  onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                  disabled={currentPage === totalPages}
                  className="flex items-center gap-1 px-3 py-2 text-sm border rounded-md hover:bg-accent disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                  <ChevronRightIcon className="h-4 w-4" />
                </button>
                <button
                  onClick={() => setCurrentPage(totalPages)}
                  disabled={currentPage === totalPages}
                  className="px-3 py-2 text-sm border rounded-md hover:bg-accent disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Last
                </button>
              </div>
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
