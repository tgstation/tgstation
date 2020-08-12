/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { setClientTheme } from '../themes';
import { loadSettings, updateSettings } from './actions';
import { selectSettings } from './selectors';

const setGlobalFontSize = fontSize => {
  document.documentElement.style
    .setProperty('font-size', fontSize + 'px');
  document.body.style
    .setProperty('font-size', fontSize + 'px');
};

export const settingsMiddleware = store => {
  let initialized = false;
  return next => action => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      storage.get('panel-settings').then(settings => {
        store.dispatch(loadSettings(settings));
      });
    }
    if (type === updateSettings.type || type === loadSettings.type) {
      // Set client theme
      const theme = payload?.theme;
      if (theme) {
        setClientTheme(theme);
      }
      // Pass action to get an updated state
      next(action);
      const settings = selectSettings(store.getState());
      // Update global UI font size
      setGlobalFontSize(settings.fontSize);
      // Save settings to the web storage
      storage.set('panel-settings', settings);
      return;
    }
    return next(action);
  };
};
