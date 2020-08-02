import { SETTINGS_VERSION } from './constants';

const initialState = {
  version: SETTINGS_VERSION,
  fontSize: 13,
  lineHeight: 1.2,
  theme: 'light',
  adminMusicVolume: 0.5,
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
