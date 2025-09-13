import { AiAnalysisDetail } from '@/components/ai-analysis-detail'

export default function AnalysisDetailPage({ params }: { params: { analysis_id: string } }) {
  return (
    <div className="space-y-6">
      <AiAnalysisDetail analysisId={params.analysis_id} />
    </div>
  )
}

