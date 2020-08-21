/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const debugReducer = (state = {}, action) => {
  const { type, payload } = action;
  if (type === 'debug/toggleKitchenSink') {
    return {
      ...state,
      kitchenSink: !state.kitchenSink,
    };
  }
  if (type === 'debug/toggleDebugLayout') {
    return {
      ...state,
      debugLayout: !state.debugLayout,
    };
  }
  return state;
};
