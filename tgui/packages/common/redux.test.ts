import { describe, it } from 'vitest';

import {
  Action,
  applyMiddleware,
  combineReducers,
  createAction,
  createStore,
  Reducer,
} from './redux';

// Dummy Reducer
const counterReducer: Reducer<number, Action<string>> = (state = 0, action) => {
  switch (action.type) {
    case 'INCREMENT':
      return state + 1;
    case 'DECREMENT':
      return state - 1;
    default:
      return state;
  }
};

// Dummy Middleware
const loggingMiddleware = (storeApi) => (next) => (action) => {
  console.log('Middleware:', action);
  return next(action);
};

// Dummy Action Creators
const increment = createAction('INCREMENT');
const decrement = createAction('DECREMENT');

describe('Redux implementation tests', () => {
  it('createStore works', ({ expect }) => {
    const store = createStore(counterReducer);
    expect(store.getState()).toBe(0);
  });

  it('createStore with applyMiddleware works', ({ expect }) => {
    const store = createStore(
      counterReducer,
      applyMiddleware(loggingMiddleware),
    );
    expect(store.getState()).toBe(0);
  });

  it('dispatch works', ({ expect }) => {
    const store = createStore(counterReducer);
    store.dispatch(increment());
    expect(store.getState()).toBe(1);
    store.dispatch(decrement());
    expect(store.getState()).toBe(0);
  });

  it('combineReducers works', ({ expect }) => {
    const rootReducer = combineReducers({
      counter: counterReducer,
    });
    const store = createStore(rootReducer);
    expect(store.getState()).toEqual({ counter: 0 });
  });

  it('createAction works', ({ expect }) => {
    const incrementAction = increment();
    expect(incrementAction).toEqual({ type: 'INCREMENT' });
    const decrementAction = decrement();
    expect(decrementAction).toEqual({ type: 'DECREMENT' });
  });
});
