/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { compose } from './fp';

/**
 * Creates a Redux store.
 */
export const createStore = (reducer, enhancer) => {
  // Apply a store enhancer (applyMiddleware is one of them).
  if (enhancer) {
    return enhancer(createStore)(reducer);
  }

  let currentState;
  let listeners = [];

  const getState = () => currentState;

  const subscribe = listener => {
    listeners.push(listener);
  };

  const dispatch = action => {
    currentState = reducer(currentState, action);
    listeners.forEach(fn => fn());
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

/**
 * Creates a store enhancer which applies middleware to all dispatched
 * actions.
 */
export const applyMiddleware = (...middlewares) => {
  return createStore => (reducer, ...args) => {
    const store = createStore(reducer, ...args);

    let dispatch = () => {
      throw new Error(
        'Dispatching while constructing your middleware is not allowed.');
    };

    const storeApi = {
      getState: store.getState,
      dispatch: (action, ...args) => dispatch(action, ...args),
    };

    const chain = middlewares.map(middleware => middleware(storeApi));
    dispatch = compose(...chain)(store.dispatch);

    return {
      ...store,
      dispatch,
    };
  };
};

/**
 * Combines reducers by running them in their own object namespaces as
 * defined in reducersObj paramter.
 *
 * Main difference from redux/combineReducers is that it preserves keys
 * in the state that are not present in the reducers object. This function
 * is also more flexible than the redux counterpart.
 */
export const combineReducers = reducersObj => {
  const keys = Object.keys(reducersObj);
  let hasChanged = false;
  return (prevState, action) => {
    const nextState = { ...prevState };
    for (let key of keys) {
      const reducer = reducersObj[key];
      const prevDomainState = prevState[key];
      const nextDomainState = reducer(prevDomainState, action);
      if (prevDomainState !== nextDomainState) {
        hasChanged = true;
        nextState[key] = nextDomainState;
      }
    }
    return hasChanged
      ? nextState
      : prevState;
  };
};
