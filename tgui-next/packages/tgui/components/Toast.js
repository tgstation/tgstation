export const Toast = props => {
  const { content, children } = props;
  return (
    <div className="Layout__toast">
      {content}
      {children}
    </div>
  );
};

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
      type: 'HIDE_TOAST',
    });
  }, 5000);
  dispatch({
    type: 'SHOW_TOAST',
    payload: { text },
  });
};

export const toastReducer = (state, action) => {
  const { type, payload } = action;

  if (type === 'SHOW_TOAST') {
    const { text } = payload;
    return {
      ...state,
      toastText: text,
    };
  }

  if (type === 'HIDE_TOAST') {
    return {
      ...state,
      toastText: null,
    };
  }

  return state;
};
