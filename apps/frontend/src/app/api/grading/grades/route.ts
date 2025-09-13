import { NextRequest, NextResponse } from 'next/server'

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:6080'

export async function GET(request: NextRequest) {
  const url = new URL(request.url)
  const qs = url.searchParams.toString()
  const target = `${API_BASE}/api/v1/grading/grades${qs ? `?${qs}` : ''}`

  try {
    const res = await fetch(target, {
      // Cache for 60s on the server, allow stale for 120s
      next: { revalidate: 60, tags: ['grading', 'grades'] },
    })

    if (!res.ok) {
      const text = await res.text()
      return NextResponse.json({ error: 'Upstream error', details: text }, { status: res.status })
    }

    const data = await res.json()
    return NextResponse.json(data, {
      headers: { 'Cache-Control': 's-maxage=60, stale-while-revalidate=120' },
    })
  } catch (err: any) {
    return NextResponse.json({ error: 'Failed to reach API', details: String(err) }, { status: 502 })
  }
}

