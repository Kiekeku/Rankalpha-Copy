import { NextRequest, NextResponse } from 'next/server';
import { revalidateTag } from 'next/cache';

// Declare the global type for TypeScript
declare global {
  var lastDataRefresh: string | undefined;
}

export async function POST(request: NextRequest) {
  /**
   * This endpoint is called by Airflow after data updates complete.
   * It triggers a refresh of the data displayed in the frontend.
   */
  
  try {
    // In a production app, you might:
    // 1. Clear client-side caches
    // 2. Trigger a WebSocket event to all connected clients
    // 3. Invalidate server-side caches
    // 4. Update a timestamp in Redis that clients check
    
    // For now, log and trigger tag-based cache invalidation for server fetches
    console.log(`Data refresh triggered at ${new Date().toISOString()}`);
    
    // You could store the last refresh time in memory or Redis
    // This can be checked by the frontend to know when to refetch data
    global.lastDataRefresh = new Date().toISOString();

    // Revalidate cached fetches tagged in BFF routes
    try {
      revalidateTag('grades');
      revalidateTag('grade');
      revalidateTag('asset');
      revalidateTag('pipeline');
      revalidateTag('health');
    } catch (e) {
      // If running in an environment that doesn't support revalidation, ignore
      console.warn('Cache revalidation skipped or failed:', e);
    }
    
    return NextResponse.json({
      status: 'success',
      message: 'Data refresh triggered',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error during data refresh:', error);
    return NextResponse.json(
      { status: 'error', message: 'Failed to trigger refresh' },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  /**
   * Get the last refresh timestamp
   */
  return NextResponse.json({
    lastRefresh: global.lastDataRefresh || null
  });
}
