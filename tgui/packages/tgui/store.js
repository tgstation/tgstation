import { flow } from 'common/fp';
import { applyMiddleware, createStore as createReduxStore } from 'common/redux';
import { Component } from 'inferno';
import { backendReducer } from './backend';
import { hotKeyMiddleware, hotKeyReducer } from './hotkeys';

export const createStore = () => {
  const reducer = flow([
    // State initializer
    (state = {}, action) => state,
    // Global state reducers
    backendReducer,
    hotKeyReducer,
    globalStateReducer,
  ]);
  const middleware = [
    // loggingMiddleware,
    hotKeyMiddleware,
  ];
  return createReduxStore(reducer, applyMiddleware(...middleware));
};

export class StoreProvider extends Component {
  getChildContext() {
    const { store } = this.props;
    return { store };
  }

  render() {
    return this.props.children;
  }
}

export const useDispatch = context => {
  return context.store.dispatch;
};

/**
 * Allocates a global variable on Redux store.
 *
 * Great when you want to store some UI state globally, without having to
 * modify DM object you're working with to have that var and export it via
 * ui_data.
 *
 * @param {any} context React context.
 * @param {string} key Key which uniquely identifies this state in Redux store.
 * @param {any} initialState Initializes your global variable with this value.
 */
export const useGlobal = (context, key, initialState) => {
  const { store } = context;
  const globalObj = store.getState().global ?? {};
  const state = (key in globalObj)
    ? globalObj[key]
    : initialState;
  const setState = nextState => {
    store.dispatch({
      type: 'setGlobal',
      payload: { key, nextState },
    });
  };
  return [state, setState];
};

/**
 * Reducer, which handles actions coming from useGlobal.
 */
const globalStateReducer = (state, action) => {
  const { type, payload } = action;
  if (type === 'setGlobal') {
    const { key, nextState } = payload;
    return {
      ...state,
      global: {
        ...state.global,
        [key]: nextState,
      },
    };
  }
  return state;
};
