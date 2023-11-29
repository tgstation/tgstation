/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export type Reducer<State = any, ActionType extends Action = AnyAction> = (
  state: State | undefined,
  action: ActionType
) => State;

export type Store<State = any, ActionType extends Action = AnyAction> = {
  dispatch: Dispatch<ActionType>;
  subscribe: (listener: () => void) => void;
  getState: () => State;
};

type MiddlewareAPI<State = any, ActionType extends Action = AnyAction> = {
  getState: () => State;
  dispatch: Dispatch<ActionType>;
};

export type Middleware = <State = any, ActionType extends Action = AnyAction>(
  storeApi: MiddlewareAPI<State, ActionType>
) => (next: Dispatch<ActionType>) => Dispatch<ActionType>;

export type Action<TType = any> = {
  type: TType;
};

export type AnyAction = Action & {
  [extraProps: string]: any;
};

export type Dispatch<ActionType extends Action = AnyAction> = (
  action: ActionType
) => void;

type StoreEnhancer = (createStoreFunction: Function) => Function;

type PreparedAction = {
  payload?: any;
  meta?: any;
};

/**
 * Creates a Redux store.
 */
export const createStore = <State, ActionType extends Action = AnyAction>(
  reducer: Reducer<State, ActionType>,
  enhancer?: StoreEnhancer
): Store<State, ActionType> => {
  // Apply a store enhancer (applyMiddleware is one of them).
  if (enhancer) {
    return enhancer(createStore)(reducer);
  }

  let currentState: State;
  let listeners: Array<() => void> = [];

  const getState = (): State => currentState;

  const subscribe = (listener: () => void): void => {
    listeners.push(listener);
  };

  const dispatch = (action: ActionType): void => {
    currentState = reducer(currentState, action);
    for (let i = 0; i < listeners.length; i++) {
      listeners[i]();
    }
  };

  // This creates the initial store by causing each reducer to be called
  // with an undefined state
  dispatch({ type: '@@INIT' } as ActionType);

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
export const applyMiddleware = (
  ...middlewares: Middleware[]
): StoreEnhancer => {
  return (
    createStoreFunction: (reducer: Reducer, enhancer?: StoreEnhancer) => Store
  ) => {
    return (reducer, ...args): Store => {
      const store = createStoreFunction(reducer, ...args);

      let dispatch: Dispatch = () => {
        throw new Error(
          'Dispatching while constructing your middleware is not allowed.'
        );
      };

      const storeApi: MiddlewareAPI = {
        getState: store.getState,
        dispatch: (action, ...args) => dispatch(action, ...args),
      };

      const chain = middlewares.map((middleware) => middleware(storeApi));
      dispatch = chain.reduceRight(
        (next, middleware) => middleware(next),
        store.dispatch
      );

      return {
        ...store,
        dispatch,
      };
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
export const combineReducers = (
  reducersObj: Record<string, Reducer>
): Reducer => {
  const keys = Object.keys(reducersObj);

  return (prevState = {}, action) => {
    const nextState = { ...prevState };
    let hasChanged = false;

    for (const key of keys) {
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
export const createAction = <TAction extends string>(
  type: TAction,
  prepare?: (...args: any[]) => PreparedAction
) => {
  const actionCreator = (...args: any[]) => {
    let action: Action<TAction> & PreparedAction = { type };

    if (prepare) {
      const prepared = prepare(...args);
      if (!prepared) {
        throw new Error('prepare function did not return an object');
      }
      action = { ...action, ...prepared };
    } else {
      action.payload = args[0];
    }

    return action;
  };

  actionCreator.toString = () => type;
  actionCreator.type = type;
  actionCreator.match = (action) => action.type === type;

  return actionCreator;
};
