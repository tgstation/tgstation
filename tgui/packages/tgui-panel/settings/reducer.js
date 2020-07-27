const initialState = {
  visible: false,
  fontSize: 12,
  lineHeight: 1.5,
};

export const settingsReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'settings/update') {
    return {
      ...state,
      ...payload,
    };
  }
  if (type === 'settings/toggle') {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  return state;
};
