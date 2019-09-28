import { flow } from 'functional';
import { createStore as createReduxStore } from 'redux';
import { backendReducer } from './backend';
import { toastReducer } from './components/Toast';
import { createLogger } from './logging';

const logger = createLogger('store');

export const createStore = () => {
  const reducer = flow([
    // State initializer
    (state = {}, action) => state,
    // Action logger
    (state, action) => {
      logger.log('action:', action.type);
      return state;
    },
    // Add other reducers to the chain
    backendReducer,
    toastReducer,
  ]);
  return createReduxStore(reducer);
};
