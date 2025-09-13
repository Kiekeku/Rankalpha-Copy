'use client'

import { useQuery } from '@tanstack/react-query'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { api, AssetDetail } from '@/lib/api'
import { TrendingUpIcon, BarChart3Icon, CalendarIcon } from 'lucide-react'

interface StockDetailModalProps {
  symbol: string | null
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function StockDetailModal({ symbol, open, onOpenChange }: StockDetailModalProps) {
  const { data: assetDetail, isLoading, error } = useQuery({
    queryKey: ['asset-detail', symbol],
    queryFn: () => api.getAssetDetail(symbol!),
    enabled: !!symbol && open,
  })

  if (!symbol) return null

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            {isLoading ? (
              <Skeleton className="h-8 w-48" />
            ) : (
              <>
                <span className="text-xl font-bold">{symbol}</span>
                {assetDetail?.company_name && (
                  <span className="text-lg text-muted-foreground">
                    - {assetDetail.company_name}
                  </span>
                )}
                {assetDetail?.current_grade && (
                  <Badge className={getGradeBadgeColor(assetDetail.current_grade.overall_grade)}>
                    Grade {assetDetail.current_grade.overall_grade}
                  </Badge>
                )}
              </>
            )}
          </DialogTitle>
        </DialogHeader>

        {isLoading ? (
          <div className="space-y-4">
            {[...Array(4)].map((_, i) => (
              <Skeleton key={i} className="h-32 w-full" />
            ))}
          </div>
        ) : error ? (
          <div className="text-center py-8">
            <p className="text-destructive">Failed to load stock details</p>
          </div>
        ) : assetDetail ? (
          <div className="space-y-6">
            {/* Current Grade & Scores */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TrendingUpIcon className="h-5 w-5" />
                  Current Performance
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-blue-600">
                      {assetDetail.current_grade.momentum_score?.toFixed(1) || 'N/A'}
                    </div>
                    <div className="text-sm text-muted-foreground">Momentum</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-green-600">
                      {assetDetail.current_grade.value_score?.toFixed(1) || 'N/A'}
                    </div>
                    <div className="text-sm text-muted-foreground">Value</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-purple-600">
                      {assetDetail.current_grade.sentiment_score?.toFixed(1) || 'N/A'}
                    </div>
                    <div className="text-sm text-muted-foreground">Sentiment</div>
                  </div>
                  <div className="text-center">
                    <div className={`text-2xl font-bold ${getGradeColor(assetDetail.current_grade.overall_grade)}`}>
                      {assetDetail.current_grade.overall_grade}
                    </div>
                    <div className="text-sm text-muted-foreground">Overall Grade</div>
                  </div>
                </div>
                <div className="mt-4 p-4 bg-muted rounded-lg">
                  <p className="text-sm">{assetDetail.current_grade.grade_explanation}</p>
                </div>
              </CardContent>
            </Card>

            {/* AI Analysis */}
            {assetDetail.ai_analysis && (
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <BarChart3Icon className="h-5 w-5" />
                    AI Analysis & Commentary
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {assetDetail.ai_analysis.commentary && (
                    <div className="mb-6">
                      <h4 className="font-semibold mb-2">Commentary</h4>
                      <p className="text-sm leading-relaxed p-4 bg-muted rounded-lg">
                        {assetDetail.ai_analysis.commentary}
                      </p>
                    </div>
                  )}
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {assetDetail.ai_analysis.market_cap && (
                      <div className="flex flex-col">
                        <span className="text-sm text-muted-foreground">Market Cap</span>
                        <span className="font-semibold">
                          ${(assetDetail.ai_analysis.market_cap / 1e9).toFixed(1)}B
                        </span>
                      </div>
                    )}
                    {assetDetail.ai_analysis.beta && (
                      <div className="flex flex-col">
                        <span className="text-sm text-muted-foreground">Beta (S&P 500)</span>
                        <span className="font-semibold">{assetDetail.ai_analysis.beta.toFixed(2)}</span>
                      </div>
                    )}
                    {assetDetail.ai_analysis.revenue_cagr_3y && (
                      <div className="flex flex-col">
                        <span className="text-sm text-muted-foreground">Revenue CAGR (3Y)</span>
                        <span className="font-semibold">{assetDetail.ai_analysis.revenue_cagr_3y}%</span>
                      </div>
                    )}
                    {assetDetail.ai_analysis.news_sentiment_30d !== undefined && (
                      <div className="flex flex-col">
                        <span className="text-sm text-muted-foreground">News Sentiment (30D)</span>
                        <span className="font-semibold">{assetDetail.ai_analysis.news_sentiment_30d}</span>
                      </div>
                    )}
                    {assetDetail.ai_analysis.short_interest_pct && (
                      <div className="flex flex-col">
                        <span className="text-sm text-muted-foreground">Short Interest</span>
                        <span className="font-semibold">{assetDetail.ai_analysis.short_interest_pct}%</span>
                      </div>
                    )}
                    {assetDetail.ai_analysis.employee_score && (
                      <div className="flex flex-col">
                        <span className="text-sm text-muted-foreground">Employee Score</span>
                        <span className="font-semibold">{assetDetail.ai_analysis.employee_score}/5.0</span>
                      </div>
                    )}
                  </div>
                </CardContent>
              </Card>
            )}


            {/* AI Headline Risks */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <CalendarIcon className="h-5 w-5" />
                  AI Headline Risk Analysis
                </CardTitle>
                <CardDescription>
                  Key risks identified from recent analysis
                </CardDescription>
              </CardHeader>
              <CardContent>
                {assetDetail.recent_news && assetDetail.recent_news.length > 0 ? (
                  <div className="space-y-4">
                    {assetDetail.recent_news.map((item, index) => (
                      <div key={index} className="flex items-start gap-3 p-3 border rounded-lg">
                        <div className="flex-1">
                          <h4 className="font-semibold text-sm mb-1">{item.headline}</h4>
                          <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            {item.analysis_date && (
                              <span>Analysis: {new Date(item.analysis_date).toLocaleDateString()}</span>
                            )}
                            <Badge variant="outline" className="text-xs bg-red-50 text-red-600">
                              Headline Risk
                            </Badge>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8 text-muted-foreground">
                    <p>No headline risks identified in recent analysis</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

function getGradeBadgeColor(grade: string) {
  switch (grade) {
    case 'A':
      return 'bg-green-100 text-green-800 hover:bg-green-200'
    case 'B':
      return 'bg-blue-100 text-blue-800 hover:bg-blue-200'
    case 'C':
      return 'bg-yellow-100 text-yellow-800 hover:bg-yellow-200'
    case 'D':
      return 'bg-orange-100 text-orange-800 hover:bg-orange-200'
    case 'F':
      return 'bg-red-100 text-red-800 hover:bg-red-200'
    default:
      return 'bg-gray-100 text-gray-800 hover:bg-gray-200'
  }
}

function getGradeColor(grade: string) {
  switch (grade) {
    case 'A':
      return 'text-green-600'
    case 'B':
      return 'text-blue-600'
    case 'C':
      return 'text-yellow-600'
    case 'D':
      return 'text-orange-600'
    case 'F':
      return 'text-red-600'
    default:
      return 'text-gray-600'
  }
}