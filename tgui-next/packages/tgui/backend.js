import { UI_DISABLED, UI_INTERACTIVE } from './constants';
import { tridentVersion } from './byond';

/**
 * This file provides a clear separation layer between backend updates
 * and what state our React app sees.
 *
 * Sometimes backend can response without a "data" field, but our final
 * state will still contain previous "data" because we are merging
 * the response with already existing state.
 */

/**
 * Creates a backend update action.
 */
export const backendUpdate = state => ({
  type: 'backendUpdate',
  payload: state,
});

/**
 * Precisely defines state changes.
 */
export const backendReducer = (state, action) => {
  const { type, payload } = action;

  if (type === 'backendUpdate') {
    // Merge config
    const config = {
      ...state.config,
      ...payload.config,
    };
    // Merge data
    const data = {
      ...state.data,
      ...payload.static_data,
      ...payload.data,
    };
    // Calculate our own fields
    const visible = config.status !== UI_DISABLED;
    const interactive = config.status === UI_INTERACTIVE;
    // IE8: Force the non-fancy setting
    if (tridentVersion <= 4) {
      config.fancy = 0;
    }
    // Return new state
    return {
      ...state,
      config,
      data,
      visible,
      interactive,
    };
  }

  return state;
};
