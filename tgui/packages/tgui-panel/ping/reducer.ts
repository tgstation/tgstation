/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp01, scale } from 'common/math';
import { pingFail, pingSuccess } from './actions';
import { PING_MAX_FAILS, PING_ROUNDTRIP_BEST, PING_ROUNDTRIP_WORST } from './constants';

type PingState = {
  roundtrip: number | undefined;
  roundtripAvg: number | undefined;
  failCount: number;
  networkQuality: number;
};

export const pingReducer = (state = {} as PingState, action) => {
  const { type, payload } = action;

  if (type === pingSuccess.type) {
    const { roundtrip } = payload;
    const prevRoundtrip = state.roundtripAvg || roundtrip;
    const roundtripAvg = Math.round(prevRoundtrip * 0.4 + roundtrip * 0.6);
    const networkQuality =
      1 - scale(roundtripAvg, PING_ROUNDTRIP_BEST, PING_ROUNDTRIP_WORST);
    return {
      roundtrip,
      roundtripAvg,
      failCount: 0,
      networkQuality,
    };
  }

  if (type === pingFail.type) {
    const { failCount = 0 } = state;
    const networkQuality = clamp01(
      state.networkQuality - failCount / PING_MAX_FAILS
    );
    const nextState: PingState = {
      ...state,
      failCount: failCount + 1,
      networkQuality,
    };
    if (failCount > PING_MAX_FAILS) {
      nextState.roundtrip = undefined;
      nextState.roundtripAvg = undefined;
    }
    return nextState;
  }

  return state;
};
