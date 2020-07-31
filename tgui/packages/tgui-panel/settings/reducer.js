const initialState = {
  visible: false,
  fontSize: 9,
  lineHeight: 1.4,
  theme: 'dark',
  adminMusicVolume: 1,
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
      adminMusicVolume: settings.adminMusicVolume,
    };
  }
  return state;
};
