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
    // Calculate our own fields
    const visible = payload.config.status !== UI_DISABLED;
    const interactive = payload.config.status === UI_INTERACTIVE;
    // Override fancy setting for IE8
    if (tridentVersion <= 4) {
      payload.config.fancy = 0;
    }
    // Merge new payload
    return {
      ...state,
      ...payload,
      visible,
      interactive,
    };
  }

  return state;
};
