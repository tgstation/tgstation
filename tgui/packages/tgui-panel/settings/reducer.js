const initialState = {
  visible: false,
  fontSize: 9,
  lineHeight: 1.5,
  theme: 'dark',
};

export const settingsReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'settings/update') {
    return {
      ...state,
      ...payload,
    };
  }
  if (type === 'settings/load') {
    const settings = payload;
    return {
      ...state,
      fontSize: settings.fontSize,
      lineHeight: settings.lineHeight,
      theme: settings.theme,
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
