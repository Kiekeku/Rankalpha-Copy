'use client'

import { useQuery } from '@tanstack/react-query'
import { AiAnalysisDetail } from '@/components/ai-analysis-detail'
import { api } from '@/lib/api'
import { Skeleton } from '@/components/ui/skeleton'

export default function AiLatestBySymbolPage({ params }: { params: { symbol: string } }) {
  const symbol = params.symbol.toUpperCase()
  const { data, isLoading, error } = useQuery({
    queryKey: ['ai-latest-symbol', symbol],
    queryFn: () => api.getLatestAiAnalysis(symbol),
  })

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[...Array(5)].map((_, i) => (<Skeleton key={i} className="h-28 w-full" />))}
      </div>
    )
  }
  if (error || !data) {
    return <div className="text-destructive">No AI analysis found for {symbol}</div>
  }

  return (
    <div className="space-y-6">
      <AiAnalysisDetail analysisId={data.analysis_id} />
    </div>
  )
}

