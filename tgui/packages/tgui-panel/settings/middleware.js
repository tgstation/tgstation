/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { setClientTheme } from '../theme';
import { loadSettings, updateSettings } from './actions';
import { selectSettings } from './selectors';

export const settingsMiddleware = store => {
  let initialized = false;
  return next => action => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      storage.get('panel-settings').then(settings => {
        if (!settings) {
          return;
        }
        if (!settings.version) {
          // Ignore previous settings, start clean.
          storage.clear();
          return;
        }
        store.dispatch(loadSettings(settings));
      });
      return next(action);
    }
    if (type === updateSettings.type || type === loadSettings.type) {
      // Set client theme
      const { theme } = payload;
      if (theme) {
        setClientTheme(theme);
      }
      // Pass action to get an updated state
      next(action);
      // Save settings to the web storage
      storage.set('panel-settings', selectSettings(store.getState()));
      return;
    }
    return next(action);
  };
};
