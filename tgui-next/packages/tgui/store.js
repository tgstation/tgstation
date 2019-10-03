import { flow } from 'common/fp';
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
  return createReduxStore(reducer);
};


const createReduxStore = reducer => {
  let currentState;
  let listeners = [];

  const getState = () => currentState;

  const subscribe = listener => {
    listeners.push(listener);
  };

  const dispatch = action => {
    currentState = reducer(currentState, action);
    listeners.forEach(l => l());
  };

  // This creates the initial store by causing each reducer to be called
  // with an undefined state
  dispatch({
    type: '@@INIT',
  });

  return {
    dispatch,
    subscribe,
    getState,
  };
};
