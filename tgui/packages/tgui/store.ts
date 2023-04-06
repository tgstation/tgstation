/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Middleware, Reducer, Store, applyMiddleware, combineReducers, createStore } from 'common/redux';
import { backendMiddleware, backendReducer } from './backend';
import { debugMiddleware, debugReducer, relayMiddleware } from './debug';

import { Component } from 'inferno';
import { assetMiddleware } from './assets';
import { createLogger } from './logging';
import { flow } from 'common/fp';

type ConfigureStoreOptions = {
  sideEffects?: boolean;
  reducer?: Reducer;
  middleware?: {
    pre?: Middleware[];
    post?: Middleware[];
  };
};

type StackAugmentor = (stack: string, error?: Error) => string;

type StoreProviderProps = {
  store: Store;
  children: any;
};

const logger = createLogger('store');

export const configureStore = (options: ConfigureStoreOptions = {}): Store => {
  const { sideEffects = true } = options;
  const reducer: Reducer = flow([
    combineReducers({
      debug: debugReducer,
      backend: backendReducer,
    }),
    options.reducer,
  ]);
  const middleware: Middleware[] = !sideEffects
    ? []
    : [
      ...(options.middleware?.pre || []),
      assetMiddleware,
      backendMiddleware,
      ...(options.middleware?.post || []),
    ];
  if (process.env.NODE_ENV !== 'production') {
    // We are using two if statements because Webpack is capable of
    // removing this specific block as dead code.
    if (sideEffects) {
      middleware.unshift(loggingMiddleware, debugMiddleware, relayMiddleware);
    }
  }
  const enhancer = applyMiddleware(...middleware);
  const store = createStore(reducer, enhancer);
  // Globals
  window.__store__ = store;
  window.__augmentStack__ = createStackAugmentor(store);
  return store;
};

const loggingMiddleware: Middleware = (store) => (next) => (action) => {
  const { type } = action;
  if (type === 'update' || type === 'backend/update') {
    logger.debug('action', { type });
  } else {
    logger.debug('action', action);
  }
  return next(action);
};

/**
 * Creates a function, which can be assigned to window.__augmentStack__
 * to augment reported stack traces with useful data for debugging.
 */
const createStackAugmentor =
  (store: Store): StackAugmentor =>
  (stack, error) => {
    if (!error) {
      error = new Error(stack.split('\n')[0]);
      error.stack = stack;
    } else if (typeof error === 'object' && !error.stack) {
      error.stack = stack;
    }
    logger.log('FatalError:', error);
    const state = store.getState();
    const config = state?.backend?.config;
    let augmentedStack = stack;
    augmentedStack += '\nUser Agent: ' + navigator.userAgent;
    augmentedStack +=
      '\nState: ' +
      JSON.stringify({
        ckey: config?.client?.ckey,
        interface: config?.interface,
        window: config?.window,
      });
    return augmentedStack;
  };

/**
 * Store provider for Inferno apps.
 */
export class StoreProvider extends Component<StoreProviderProps> {
  getChildContext() {
    const { store } = this.props;
    return { store };
  }

  render() {
    return this.props.children;
  }
}
