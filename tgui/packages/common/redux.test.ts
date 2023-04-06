import { Reducer, applyMiddleware, combineReducers, createAction, createStore } from './redux';

type TestState = {
  count: number;
};

describe('reduxLite', () => {
  const INCREMENT = 'INCREMENT';

  const increment = createAction(INCREMENT);

  const counterReducer: Reducer<TestState> = (state = { count: 0 }, action) => {
    switch (action.type) {
      case INCREMENT:
        return { count: state.count + 1 };
      default:
        return state;
    }
  };

  test('createStore, getState and dispatch', () => {
    const store = createStore(counterReducer);
    expect(store.getState()).toEqual({ count: 0 });

    store.dispatch(increment());
    expect(store.getState()).toEqual({ count: 1 });
  });

  test('applyMiddleware', () => {
    const middleware = (store) => (next) => (action) => {
      if (action.type === INCREMENT) {
        next({ ...action, payload: 2 });
      } else {
        next(action);
      }
    };

    const enhancedStore = createStore(
      counterReducer,
      applyMiddleware(middleware)
    );
    enhancedStore.dispatch(increment());
    expect(enhancedStore.getState()).toEqual({ count: 2 });
  });

  test('combineReducers', () => {
    const rootReducer = combineReducers({ counter: counterReducer });
    const store = createStore(rootReducer);

    expect(store.getState()).toEqual({ counter: { count: 0 } });

    store.dispatch(increment());
    expect(store.getState()).toEqual({ counter: { count: 1 } });
  });

  test('createAction', () => {
    const action = increment();
    expect(action).toEqual({ type: INCREMENT, payload: undefined });
  });
});
