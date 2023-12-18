/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';

import { setClientTheme } from '../themes';
import {
  addHighlightSetting,
  loadSettings,
  removeHighlightSetting,
  updateHighlightSetting,
  updateSettings,
} from './actions';
import { FONTS_DISABLED } from './constants';
import { selectSettings } from './selectors';

let overrideRule = null;
let overrideFontFamily = null;
let overrideFontSize = null;

const updateGlobalOverrideRule = () => {
  let fontFamily = '';

  if (overrideFontFamily !== null) {
    fontFamily = `font-family: ${overrideFontFamily} !important;`;
  }

  const constructedRule = `body * :not(.Icon) {
    ${fontFamily}
  }`;

  if (overrideRule === null) {
    overrideRule = document.createElement('style');
    document.querySelector('head').append(overrideRule);
  }

  // no other way to force a CSS refresh other than to update its innerText
  overrideRule.innerText = constructedRule;

  document.body.style.setProperty('font-size', overrideFontSize);
};

const setGlobalFontSize = (fontSize) => {
  overrideFontSize = `${fontSize}px`;
};

const setGlobalFontFamily = (fontFamily) => {
  if (fontFamily === FONTS_DISABLED) fontFamily = null;
  overrideFontFamily = fontFamily;
};

export const settingsMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      storage.get('panel-settings').then((settings) => {
        store.dispatch(loadSettings(settings));
      });
    }
    if (
      type === updateSettings.type ||
      type === loadSettings.type ||
      type === addHighlightSetting.type ||
      type === removeHighlightSetting.type ||
      type === updateHighlightSetting.type
    ) {
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
      setGlobalFontFamily(settings.fontFamily);
      updateGlobalOverrideRule();
      // Save settings to the web storage
      storage.set('panel-settings', settings);
      return;
    }
    return next(action);
  };
};
