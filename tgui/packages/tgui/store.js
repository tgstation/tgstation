/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { flow } from 'common/fp';
import { applyMiddleware, combineReducers, createStore } from 'common/redux';
import { Component } from 'inferno';
import { assetMiddleware } from './assets';
import { backendMiddleware, backendReducer } from './backend';
import { debugMiddleware, debugReducer, relayMiddleware } from './debug';
import { createLogger } from './logging';

const logger = createLogger('store');

export const configureStore = (options = {}) => {
  const reducer = flow([
    combineReducers({
      debug: debugReducer,
      backend: backendReducer,
    }),
    options.reducer,
  ]);
  const middleware = [
    ...(options.middleware?.pre || []),
    assetMiddleware,
    backendMiddleware,
    ...(options.middleware?.post || []),
  ];
  if (process.env.NODE_ENV !== 'production') {
    middleware.unshift(
      loggingMiddleware,
      debugMiddleware,
      relayMiddleware);
  }
  const enhancer = applyMiddleware(...middleware);
  const store = createStore(reducer, enhancer);
  // Globals
  window.__store__ = store;
  window.__augmentStack__ = createStackAugmentor(store);
  return store;
};

const loggingMiddleware = store => next => action => {
  const { type, payload } = action;
  if (type === 'backend/update') {
    logger.debug('action', { type });
  }
  else {
    logger.debug('action', action);
  }
  return next(action);
};

/**
 * Creates a function, which can be assigned to window.__augmentStack__
 * to augment reported stack traces with useful data for debugging.
 */
const createStackAugmentor = store => (stack, error) => {
  if (error && typeof error === 'object' && !error.stack) {
    error.stack = stack;
  }
  logger.log('FatalError:', error || stack);
  const state = store.getState();
  let augmentedStack = stack;
  augmentedStack += '\nUser Agent: ' + navigator.userAgent;
  augmentedStack += '\nState: ' + JSON.stringify({
    config: state?.backend?.config,
    suspended: state?.backend?.suspended,
    suspending: state?.backend?.suspending,
  });
  return augmentedStack;
};

/**
 * Store provider for Inferno apps.
 */
export class StoreProvider extends Component {
  getChildContext() {
    const { store } = this.props;
    return { store };
  }

  render() {
    return this.props.children;
  }
}
