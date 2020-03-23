import { flow } from 'common/fp';
import { applyMiddleware, createStore as createReduxStore } from 'common/redux';
import { backendReducer } from './backend';
import { hotKeyMiddleware, hotKeyReducer } from './hotkeys';
import { createLogger } from './logging';

const logger = createLogger('store');

// const loggingMiddleware = store => next => action => {
//   const { type, payload } = action;
//   logger.log('dispatching', type);
//   next(action);
// };

export const createStore = () => {
  const reducer = flow([
    // State initializer
    (state = {}, action) => state,
    // Global state reducers
    backendReducer,
    hotKeyReducer,
  ]);
  const middleware = [
    // loggingMiddleware,
    hotKeyMiddleware,
  ];
  return createReduxStore(reducer, applyMiddleware(...middleware));
};
