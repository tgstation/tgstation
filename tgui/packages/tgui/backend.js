/**
 * This file provides a clear separation layer between backend updates
 * and what state our React app sees.
 *
 * Sometimes backend can response without a "data" field, but our final
 * state will still contain previous "data" because we are merging
 * the response with already existing state.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { UI_DISABLED, UI_INTERACTIVE } from './constants';
import { callByond } from './byond';

export const backendUpdate = state => ({
  type: 'backend/update',
  payload: state,
});

export const backendSetSharedState = (key, nextState) => ({
  type: 'backend/setSharedState',
  payload: { key, nextState },
});

export const backendReducer = (state, action) => {
  const { type, payload } = action;

  if (type === 'backend/update') {
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
    // Merge shared states
    const shared = { ...state.shared };
    if (payload.shared) {
      for (let key of Object.keys(payload.shared)) {
        const value = payload.shared[key];
        if (value === '') {
          shared[key] = undefined;
        }
        else {
          shared[key] = JSON.parse(value);
        }
      }
    }
    // Calculate our own fields
    const visible = config.status !== UI_DISABLED;
    const interactive = config.status === UI_INTERACTIVE;
    // Return new state
    return {
      ...state,
      config,
      data,
      shared,
      visible,
      interactive,
    };
  }

  if (type === 'backend/setSharedState') {
    const { key, nextState } = payload;
    return {
      ...state,
      shared: {
        ...state.shared,
        [key]: nextState,
      },
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
 * be used in functional components.
 *
 * @return {BackendState & {
 *   act: (action: string, params?: object) => void,
 * }}
 */
export const useBackend = context => {
  const { store } = context;
  const state = store.getState();
  const ref = state.config.ref;
  const act = (action, params = {}) => {
    callByond('', {
      src: ref,
      action,
      ...params,
    });
  };
  return { ...state, act };
};

/**
 * Allocates state on Redux store without sharing it with other clients.
 *
 * Use it when you want to have a stateful variable in your component
 * that persists between renders, but will be forgotten after you close
 * the UI.
 *
 * It is a lot more performant than `setSharedState`.
 *
 * @param {any} context React context.
 * @param {string} key Key which uniquely identifies this state in Redux store.
 * @param {any} initialState Initializes your global variable with this value.
 */
export const useLocalState = (context, key, initialState) => {
  const { store } = context;
  const state = store.getState();
  const sharedStates = state.shared ?? {};
  const sharedState = (key in sharedStates)
    ? sharedStates[key]
    : initialState;
  return [
    sharedState,
    nextState => {
      store.dispatch(backendSetSharedState(key, nextState));
    },
  ];
};

/**
 * Allocates state on Redux store, and **shares** it with other clients
 * in the game.
 *
 * Use it when you want to have a stateful variable in your component
 * that persists not only between renders, but also gets pushed to other
 * clients that observe this UI.
 *
 * This makes creation of observable s
 *
 * @param {any} context React context.
 * @param {string} key Key which uniquely identifies this state in Redux store.
 * @param {any} initialState Initializes your global variable with this value.
 */
export const useSharedState = (context, key, initialState) => {
  const { store } = context;
  const state = store.getState();
  const ref = state.config.ref;
  const sharedStates = state.shared ?? {};
  const sharedState = (key in sharedStates)
    ? sharedStates[key]
    : initialState;
  return [
    sharedState,
    nextState => {
      callByond('', {
        src: ref,
        action: 'tgui:setSharedState',
        key,
        value: JSON.stringify(nextState) || '',
      });
    },
  ];
};
