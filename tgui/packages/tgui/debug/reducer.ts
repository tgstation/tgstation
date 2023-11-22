/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { zustandStore } from '..';

export const debugReducer = (state = {}, action) => {
  const currState = zustandStore?.getState();

  if (!currState) {
    return currState;
  }

  const { type, payload } = action;

  if (type === 'debug/toggleKitchenSink') {
    return {
      ...currState,
      kitchenSink: !currState.kitchenSink,
    };
  }
  if (type === 'debug/toggleDebugLayout') {
    return {
      ...currState,
      debugLayout: !currState?.debugLayout,
    };
  }
  return currState;
};
