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
