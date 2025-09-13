'use client';

import { useDataRefresh } from '@/lib/use-data-refresh';
import { useEffect } from 'react';
import { useToast } from '@/components/ui/use-toast';

export function DataRefreshMonitor() {
  const { lastChange } = useDataRefresh({ intervalMs: 300_000, cooldownMs: 900_000 }); // 5m poll, 15m cooldown
  const { toast } = useToast();

  useEffect(() => {
    if (lastChange) {
      toast({
        title: 'Data Updated',
        description: `New data as of ${lastChange.toLocaleString()}`,
        duration: 4000,
      });
    }
  }, [lastChange, toast]);

  return null; // This component doesn't render anything visible
}
