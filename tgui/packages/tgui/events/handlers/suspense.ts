import { flushSync } from 'react-dom';
import { focusMap } from '../../focus';
import { logger } from '../../logging';
import { suspendRenderer } from '../../renderer';
import {
  configAtom,
  resetStore,
  store,
  suspendedAtom,
  suspendingAtom,
} from '../store';

/// --------- Handlers ------------------------------------------------------///

let suspendInterval: NodeJS.Timeout | null = null;

/** Resets all state and refocuses byond window */
export function suspend(): void {
  suspendRenderer();

  if (suspendInterval) clearInterval(suspendInterval);

  /* Render the suspended state now. If DM reuses this window for the next UI before */
  /* React renders on its own, the same interface stays mounted with */
  /* its old state, and the window stays hidden when the size is unchanged. */
  flushSync(() => {
    resetStore();
    store.set(configAtom, (prev) => ({
      ...prev,
      title: '',
      status: 1,
    }));
    store.set(suspendingAtom, false);
    store.set(suspendedAtom, Date.now());
  });

  Byond.winset(Byond.windowId, {
    'is-visible': false,
  });

  focusMap();
}

/// --------- Helpers -------------------------------------------------------///

const TWO_SECONDS = 2000;

function suspendMsg(): void {
  Byond.sendMessage('suspend');
}

/** Signals Byond to dismiss the window */
export function suspendStart(): void {
  if (suspendInterval) clearInterval(suspendInterval);

  store.set(suspendingAtom, true);

  logger.log(`suspending (${Byond.windowId})`);
  suspendMsg();
  suspendInterval = setInterval(suspendMsg, TWO_SECONDS);
}
