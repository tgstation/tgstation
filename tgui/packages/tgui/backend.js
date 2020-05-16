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

import { perf } from 'common/perf';
import { callByond } from './byond';
import { UI_DISABLED, UI_INTERACTIVE } from './constants';
import { releaseHeldKeys } from './hotkeys';
import { createLogger } from './logging';

const logger = createLogger('backend');

const SUSPEND_TIMEOUT = 1500;

export const backendUpdate = state => ({
  type: 'backend/update',
  payload: state,
});

export const backendSetSharedState = (key, nextState) => ({
  type: 'backend/setSharedState',
  payload: { key, nextState },
});

export const backendSuspendStart = () => ({
  type: 'backend/suspendStart',
});

export const backendSuspendSuccess = () => ({
  type: 'backend/suspendSuccess',
  payload: {
    timestamp: Date.now(),
  },
});

export const backendReducer = (state = {}, action) => {
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
      assets: payload.assets || {},
      data,
      shared,
      visible,
      interactive,
      suspended: false,
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

  if (type === 'backend/suspendStart') {
    return {
      ...state,
      suspending: true,
    };
  }

  if (type === 'backend/suspendSuccess') {
    const { timestamp } = payload;
    return {
      ...state,
      data: {},
      shared: {},
      config: {
        ...state.config,
        title: '',
        status: 1,
      },
      suspending: false,
      suspended: timestamp,
    };
  }

  return state;
};

export const backendMiddleware = store => {
  let suspendTimer = null;
  return next => action => {
    const { suspended } = selectBackend(store.getState());
    const { type, payload } = action;

    if (type === 'backend/suspendStart' && !suspendTimer) {
      logger.log(`suspending (${window.__windowId__})`);
      callByond('', {
        src: window.__ref__,
        action: 'tgui:close',
        window_id: window.__windowId__,
      });
      // Show a bluescreen if failed to suspend or force-close in time.
      suspendTimer = setTimeout(() => {
        throw new Error(`Failed to suspend '${window.__windowId__}'.`);
      }, SUSPEND_TIMEOUT);
    }

    if (type === 'backend/suspendSuccess') {
      clearTimeout(suspendTimer);
      suspendTimer = null;
      releaseHeldKeys();
      callByond('winset', {
        id: window.__windowId__,
        'is-visible': false,
      });
    }

    if (type === 'backend/update' && suspended) {
      // We schedule this for the next tick here because resizing and unhiding
      // during the same tick will flash with a white background.
      setImmediate(() => {
        perf.mark('resume/start');
        // Doublecheck if we are not re-suspended.
        const { suspended } = selectBackend(store.getState());
        if (suspended) {
          return;
        }
        callByond('winset', {
          id: window.__windowId__,
          'is-visible': true,
        });
        perf.mark('resume/finish');
        if (process.env.NODE_ENV !== 'production') {
          logger.log('visible in',
            perf.measure('render/finish', 'resume/finish'));
        }
      });
    }

    return next(action);
  };
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
 *     user: {
 *       name: string,
 *       ckey: string,
 *       observer: number,
 *     },
 *     window: {
 *       id: string,
 *       key: string,
 *       size: [number, number],
 *     },
 *     ref: string,
 *   },
 *   data: any,
 *   assets: any,
 *   shared: any,
 *   visible: boolean,
 *   interactive: boolean,
 *   suspending: boolean,
 *   suspended: boolean,
 * }}
 */

/**
 * Selects a backend-related slice of Redux state
 *
 * @return {BackendState}
 */
export const selectBackend = state => state.backend || {};

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
  const state = selectBackend(store.getState());
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
  const state = selectBackend(store.getState());
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
  const state = selectBackend(store.getState());
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
