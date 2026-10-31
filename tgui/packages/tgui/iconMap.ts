import { atom } from 'jotai';
import { store } from './events/store';

type IconMapState = {
  url?: string;
  status: 'idle' | 'loading' | 'ready' | 'error';
};

/** The state of the icon map load, read by the notice and the routed component */
export const iconMapStateAtom = atom<IconMapState>({ status: 'idle' });

const ATTEMPT_TIMEOUT = 10_000;
const RETRY_DELAYS = [1_000, 3_000];

let active:
  | { url: string; controller: AbortController; promise: Promise<void> }
  | undefined;

/** Returns the map if it's a non-empty object of icon refs, throws otherwise */
function validateIconMap(value: unknown): Record<string, string> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Invalid or empty icon reference map');
  }
  const references = Object.values(value);
  // The generator only writes refs like "[0xc000049]", so an all-string error body is not a map
  if (
    !references.length ||
    references.some(
      (reference) => typeof reference !== 'string' || reference[0] !== '[',
    )
  ) {
    throw new Error('Invalid or empty icon reference map');
  }
  return value as Record<string, string>;
}

/**
 * Fetches and checks the map once.
 *
 * Gives up after ATTEMPT_TIMEOUT or when the load is aborted. Retries skip the
 * browser cache.
 */
async function fetchMap(url: string, signal: AbortSignal, retry: boolean) {
  const controller = new AbortController();
  const abort = () => controller.abort();
  signal.addEventListener('abort', abort, { once: true });
  if (signal.aborted) {
    controller.abort();
  }
  const timeout = setTimeout(abort, ATTEMPT_TIMEOUT);
  try {
    const response = await fetch(url, {
      signal: controller.signal,
      cache: retry ? 'reload' : 'default',
    });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return validateIconMap(await response.json());
  } finally {
    clearTimeout(timeout);
    signal.removeEventListener('abort', abort);
  }
}

/** Waits out a retry delay, or stops waiting as soon as the load is aborted */
function waitForRetry(delay: number, signal: AbortSignal): Promise<void> {
  return new Promise((resolve) => {
    const finish = () => {
      clearTimeout(timer);
      signal.removeEventListener('abort', finish);
      resolve();
    };
    const timer = setTimeout(finish, delay);
    signal.addEventListener('abort', finish, { once: true });
    if (signal.aborted) {
      finish();
    }
  });
}

/**
 * Tries the map once, then again after each of RETRY_DELAYS, and marks it
 * ready or failed. Stops quietly once a newer load aborts it.
 */
async function runLoad(url: string, signal: AbortSignal) {
  for (let attempt = 0; attempt <= RETRY_DELAYS.length; attempt++) {
    if (signal.aborted) {
      return;
    }
    try {
      const map = await fetchMap(url, signal, attempt > 0);
      // An older request must never overwrite a map from a newer asset message.
      if (signal.aborted) {
        return;
      }
      Byond.iconRefMap = map;
      store.set(iconMapStateAtom, { url, status: 'ready' });
      return;
    } catch {
      if (signal.aborted) {
        return;
      }
      if (attempt === RETRY_DELAYS.length) {
        store.set(iconMapStateAtom, { url, status: 'error' });
        return;
      }
      await waitForRetry(RETRY_DELAYS[attempt], signal);
    }
  }
}

/**
 * Loads the icon map from this url, unless it's already loading or loaded.
 *
 * A different url aborts the load that's running, so an old map can't land
 * over a newer one. The promise resolves once the load is done, worked or not.
 */
export function loadIconMap(url: string): Promise<void> {
  if (active?.url === url) {
    return active.promise;
  }
  const state = store.get(iconMapStateAtom);
  if (state.url === url && state.status === 'ready') {
    return Promise.resolve();
  }

  active?.controller.abort();
  const controller = new AbortController();
  store.set(iconMapStateAtom, { url, status: 'loading' });
  const promise = runLoad(url, controller.signal).finally(() => {
    if (active?.controller === controller) {
      active = undefined;
    }
  });
  active = { url, controller, promise };
  return promise;
}

/**
 * Loads the map again after it failed, for the notice's retry button.
 *
 * Does nothing unless the last load failed, so clicking again while it's
 * loading can't start a second one.
 */
export function retryIconMap(): void {
  const state = store.get(iconMapStateAtom);
  if (state.url && state.status === 'error') {
    void loadIconMap(state.url);
  }
}
