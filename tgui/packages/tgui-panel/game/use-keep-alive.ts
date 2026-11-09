import { useAtomValue, useSetAtom } from 'jotai';
import { useEffect } from 'react';
import { lastPingedAtAtom } from '../ping/atoms';
import { connectionLostAtAtom } from './atoms';

/** Custom hook that checks whether the panel is still receiving pings */
export function useKeepAlive() {
  // Ensure the derived atom (and thus the clock) is subscribed.
  useAtomValue(connectionLostAtAtom);

  // Clears stale ping timestamp across HMR/reloads to avoid a one-frame “lost” flash.
  const setLastPingedAt = useSetAtom(lastPingedAtAtom);
  useEffect(() => {
    setLastPingedAt(null);
  }, [setLastPingedAt]);
}
