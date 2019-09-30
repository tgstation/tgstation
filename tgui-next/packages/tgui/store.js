import { flow } from 'functional';
import { createStore as createReduxStore, applyMiddleware } from 'redux';
import { backendReducer } from './backend';
import { toastReducer } from './components/Toast';
import { createLogger } from './logging';

const logger = createLogger('store');

// const loggingMiddleware = store => next => action => {
//   const { type, payload } = action;
//   logger.log('dispatching', type);
//   const result = next(action);
//   return result;
// };

export const createStore = () => {
  const reducer = flow([
    // State initializer
    (state = {}, action) => state,
    // Global state reducers
    backendReducer,
    toastReducer,
  ]);
  const middleware = [
    // loggingMiddleware,
  ];
  return createReduxStore(reducer,
    applyMiddleware(...middleware));
};
