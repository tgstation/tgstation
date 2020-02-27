import { UI_DISABLED, UI_INTERACTIVE } from './constants';
import { tridentVersion, act as _act } from './byond';

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

/**
 * @typedef BackendState
 * @type {{
 *   config: {
 *     title: string,
 *     status: number,
 *     screen: string,
 *     style: string,
 *     interface: string,
 *     fancy: number,
 *     locked: number,
 *     observer: number,
 *     window: string,
 *     ref: string,
 *   },
 *   data: any,
 *   visible: boolean,
 *   interactive: boolean,
 * }}
 */

/**
 * A React hook (sort of) for getting tgui state and related functions.
 *
 * This is supposed to be replaced with a real React Hook, which can only
 * be used in functional components. DO NOT use it in class-based components!
 *
 * @return {BackendState & {
 *   act: (action: string, params?: object) => void,
 * }}
 */
export const useBackend = props => {
  // TODO: Dispatch "act" calls as Redux actions
  const { state, dispatch } = props;
  const ref = state.config.ref;
  const act = (action, params = {}) => _act(ref, action, params);
  return {
    ...state,
    act,
  };
};
