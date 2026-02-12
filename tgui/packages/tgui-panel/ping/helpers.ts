import { scale } from 'tgui-core/math';
import { store } from '../events/store';
import { lastPingedAtAtom, pingAtom } from './atoms';
import {
  PING_QUEUE_SIZE,
  PING_ROUNDTRIP_BEST,
  PING_ROUNDTRIP_WORST,
  PING_TIMEOUT,
} from './constants';

let index = 0;
export const pings: Ping[] = [];

type Ping = {
  index: number;
  sentAt: number;
} | null;

/** Sends a ping to byond */
export function sendPing(): void {
  for (let i = 0; i < PING_QUEUE_SIZE; i++) {
    const ping = pings[i];
    if (ping && Date.now() - ping.sentAt > PING_TIMEOUT) {
      pings[i] = null;
      pingFail();
    }
  }

  const ping = { index, sentAt: Date.now() };
  pings[index] = ping;
  Byond.sendMessage('ping', { index });
  index = (index + 1) % PING_QUEUE_SIZE;
}

export function pingSuccess(roundtrip: number): void {
  const state = store.get(pingAtom);
  const prevRoundtrip = state.roundtripAvg || roundtrip;
  const roundtripAvg = Math.round(prevRoundtrip * 0.4 + roundtrip * 0.6);

  const networkQuality =
    1 - scale(roundtripAvg, PING_ROUNDTRIP_BEST, PING_ROUNDTRIP_WORST);

  store.set(pingAtom, {
    roundtrip,
    roundtripAvg,
    failCount: 0,
    networkQuality,
  });

  store.set(lastPingedAtAtom, Date.now());
}

export function pingFail(): void {
  const state = store.get(pingAtom);
  const { failCount = 0 } = state;

  const networkQuality = Math.max(
    0,
    state.networkQuality - failCount / PING_QUEUE_SIZE,
  );

  const nextState = {
    ...state,
    failCount: failCount + 1,
    networkQuality,
  };

  if (failCount > PING_QUEUE_SIZE) {
    nextState.roundtrip = undefined;
    nextState.roundtripAvg = undefined;
  }

  store.set(pingAtom, nextState);
}
