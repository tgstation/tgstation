import { Action, Reducer, applyMiddleware, combineReducers, createAction, createStore } from './redux';

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
  test('createStore works', () => {
    const store = createStore(counterReducer);
    expect(store.getState()).toBe(0);
  });

  test('createStore with applyMiddleware works', () => {
    const store = createStore(
      counterReducer,
      applyMiddleware(loggingMiddleware)
    );
    expect(store.getState()).toBe(0);
  });

  test('dispatch works', () => {
    const store = createStore(counterReducer);
    store.dispatch(increment());
    expect(store.getState()).toBe(1);
    store.dispatch(decrement());
    expect(store.getState()).toBe(0);
  });

  test('combineReducers works', () => {
    const rootReducer = combineReducers({
      counter: counterReducer,
    });
    const store = createStore(rootReducer);
    expect(store.getState()).toEqual({ counter: 0 });
  });

  test('createAction works', () => {
    const incrementAction = increment();
    expect(incrementAction).toEqual({ type: 'INCREMENT' });
    const decrementAction = decrement();
    expect(decrementAction).toEqual({ type: 'DECREMENT' });
  });
});
