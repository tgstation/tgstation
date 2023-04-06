import { configureStore } from './store';
import { createStore } from 'common/redux';

// Mock the global window object
global.window = Object.create(window);

// Simple reducer function for testing
const testReducer = (state: { message?: string }, action) => {
  switch (action.type) {
    case 'TEST_ACTION':
      return { ...state, message: action.payload };
    default:
      return state;
  }
};

describe('configureStore', () => {
  it('creates a store with default options', () => {
    const store = configureStore();

    expect(store).toBeDefined();
    expect(store).toEqual(expect.any(Object));
    expect(store.dispatch).toBeDefined();
    expect(store.getState).toBeDefined();
    expect(global.window.__store__).toEqual(store);
    expect(global.window.__augmentStack__).toEqual(expect.any(Function));
  });

  it('creates a store with custom middleware', () => {
    const customMiddleware = (store) => (next) => (action) => {
      console.log('customMiddleware:', action);
      return next(action);
    };

    const store = configureStore({
      sideEffects: true,
      middleware: {
        pre: [customMiddleware],
      },
    });

    expect(store).toBeDefined();
    expect(store.dispatch).toBeDefined();
    expect(store.getState).toBeDefined();
  });

  it('creates a store without side effects', () => {
    const store = configureStore({
      sideEffects: false,
    });

    // Check if the store is created successfully
    expect(store).toBeDefined();
    expect(store.dispatch).toBeDefined();
    expect(store.getState).toBeDefined();

    // Check if the store is different from the default store created by `createStore`
    const defaultStore = createStore(testReducer);
    expect(store).not.toEqual(defaultStore);
  });

  it('creates a store with custom reducer', () => {
    const store = createStore(testReducer);

    expect(store).toBeDefined();
    expect(store.dispatch).toBeDefined();
    expect(store.getState).toBeDefined();
    expect(store.getState().message).toBeUndefined();

    // Test the custom reducer by dispatching a test action
    store.dispatch({ type: 'TEST_ACTION', payload: 'Hello, World!' });
    expect(store.getState().message).toBe('Hello, World!');
  });
});
