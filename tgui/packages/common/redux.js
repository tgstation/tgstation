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

  const subscribe = (listener) => {
    listeners.push(listener);
  };

  const dispatch = (action) => {
    currentState = reducer(currentState, action);
    for (let i = 0; i < listeners.length; i++) {
      listeners[i]();
    }
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
  // prettier-ignore
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
export const combineReducers = (reducersObj) => {
  const keys = Object.keys(reducersObj);
  let hasChanged = false;
  return (prevState = {}, action) => {
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
    return hasChanged ? nextState : prevState;
  };
};

/**
 * A utility function to create an action creator for the given action
 * type string. The action creator accepts a single argument, which will
 * be included in the action object as a field called payload. The action
 * creator function will also have its toString() overriden so that it
 * returns the action type, allowing it to be used in reducer logic that
 * is looking for that action type.
 *
 * @param {string} type The action type to use for created actions.
 * @param {any} prepare (optional) a method that takes any number of arguments
 * and returns { payload } or { payload, meta }. If this is given, the
 * resulting action creator will pass it's arguments to this method to
 * calculate payload & meta.
 *
 * @public
 */
export const createAction = (type, prepare = null) => {
  const actionCreator = (...args) => {
    if (!prepare) {
      return { type, payload: args[0] };
    }
    const prepared = prepare(...args);
    if (!prepared) {
      throw new Error('prepare function did not return an object');
    }
    const action = { type };
    if ('payload' in prepared) {
      action.payload = prepared.payload;
    }
    if ('meta' in prepared) {
      action.meta = prepared.meta;
    }
    return action;
  };
  actionCreator.toString = () => '' + type;
  actionCreator.type = type;
  actionCreator.match = (action) => action.type === type;
  return actionCreator;
};

// Implementation specific
// --------------------------------------------------------

export const useDispatch = (context) => {
  return context.store.dispatch;
};

export const useSelector = (context, selector) => {
  return selector(context.store.getState());
};
