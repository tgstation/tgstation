/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { flow } from 'common/fp';
import { applyMiddleware, combineReducers, createStore as createReduxStore } from 'common/redux';
import { Component } from 'inferno';
import { backendMiddleware, backendReducer } from './backend';
import { debugReducer } from './debug';
import { hotKeyMiddleware } from './hotkeys';
import { createLogger } from './logging';
import { assetMiddleware } from './assets';

const logger = createLogger('store');

export const createStore = () => {
  const reducer = flow([
    // State initializer
    (state = {}, action) => state,
    combineReducers({
      debug: debugReducer,
      backend: backendReducer,
    }),
  ]);
  const middleware = [
    process.env.NODE_ENV !== 'production' && loggingMiddleware,
    assetMiddleware,
    hotKeyMiddleware,
    backendMiddleware,
  ];
  return createReduxStore(reducer,
    applyMiddleware(...middleware.filter(Boolean)));
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

export class StoreProvider extends Component {
  getChildContext() {
    const { store } = this.props;
    return { store };
  }

  render() {
    return this.props.children;
  }
}

export const useDispatch = context => {
  return context.store.dispatch;
};
