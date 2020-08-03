/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { pingSuccess } from '../ping/actions';
import { connectionLost, connectionRestored, roundRestarted } from './actions';
import { selectGameState } from './selectors';

const withTimestamp = action => ({
  ...action,
  meta: {
    ...action.meta,
    now: Date.now(),
  },
});

export const gameMiddleware = store => {
  let lastPingedAt;
  setInterval(() => {
    const state = store.getState();
    if (!state) {
      return;
    }
    const game = selectGameState(state);
    const pingsAreFailing = lastPingedAt
      && Date.now() >= lastPingedAt + 10000;
    if (!game.connectionLostAt && pingsAreFailing) {
      store.dispatch(connectionLost());
    }
    if (game.connectionLostAt && !pingsAreFailing) {
      store.dispatch(connectionRestored());
    }
  }, 1000);
  return next => action => {
    const { type, payload, meta } = action;
    if (type === pingSuccess.type) {
      lastPingedAt = meta.now;
      return next(action);
    }
    if (type === roundRestarted.type) {
      return next(withTimestamp(action));
    }
    if (type === connectionLost.type) {
      return next(withTimestamp(action));
    }
    return next(action);
  };
};
