import { pureComponentHooks } from 'common/react';

export const Toast = props => {
  const { content, children } = props;
  return (
    <div className="Layout__toast">
      {content}
      {children}
    </div>
  );
};

Toast.defaultHooks = pureComponentHooks;

let toastTimeout;

/**
 * Shows a toast at the bottom of the screen.
 *
 * Takes the store's dispatch function, and text as a second argument.
 */
export const showToast = (dispatch, text) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout);
  }
  toastTimeout = setTimeout(() => {
    toastTimeout = undefined;
    dispatch({
      type: 'hideToast',
    });
  }, 5000);
  dispatch({
    type: 'showToast',
    payload: { text },
  });
};

export const toastReducer = (state, action) => {
  const { type, payload } = action;

  if (type === 'showToast') {
    const { text } = payload;
    return {
      ...state,
      toastText: text,
    };
  }

  if (type === 'hideToast') {
    return {
      ...state,
      toastText: null,
    };
  }

  return state;
};
