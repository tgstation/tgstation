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

let statFontTimer: NodeJS.Timeout;
let statTabsTimer: NodeJS.Timeout;
let overrideRule: HTMLStyleElement;
let overrideFontFamily: string | undefined;
let overrideFontSize: string;

/** Updates the global CSS rule to override the font family and size. */
function updateGlobalOverrideRule() {
  let fontFamily = '';

  if (overrideFontFamily !== undefined) {
    fontFamily = `font-family: ${overrideFontFamily} !important;`;
  }

  const constructedRule = `body * :not(.Icon) {
    ${fontFamily}
  }`;

  if (overrideRule === undefined) {
    overrideRule = document.createElement('style');
    document.querySelector('head')!.append(overrideRule);
  }

  // no other way to force a CSS refresh other than to update its innerText
  overrideRule.innerText = constructedRule;

  document.body.style.setProperty('font-size', overrideFontSize);
}

function setGlobalFontSize(
  fontSize: string,
  statFontSize: string,
  statLinked: boolean,
) {
  overrideFontSize = `${fontSize}px`;

  // Used solution from theme.ts
  clearInterval(statFontTimer);
  Byond.command(
    `.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`,
  );
  statFontTimer = setTimeout(() => {
    Byond.command(
      `.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`,
    );
  }, 1500);
}

function setGlobalFontFamily(fontFamily: string) {
  overrideFontFamily = fontFamily === FONTS_DISABLED ? undefined : fontFamily;
}

function setStatTabsStyle(style: string) {
  clearInterval(statTabsTimer);
  Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  statTabsTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  }, 1500);
}

export function settingsMiddleware(store) {
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
      type !== updateSettings.type &&
      type !== loadSettings.type &&
      type !== addHighlightSetting.type &&
      type !== removeHighlightSetting.type &&
      type !== updateHighlightSetting.type
    ) {
      return next(action);
    }

    // Set client theme
    const theme = payload?.theme;
    if (theme) {
      setClientTheme(theme);
    }

    // Pass action to get an updated state
    next(action);

    const settings = selectSettings(store.getState());

    // Update stat panel settings
    setStatTabsStyle(settings.statTabsStyle);

    // Update global UI font size
    setGlobalFontSize(
      settings.fontSize,
      settings.statFontSize,
      settings.statLinked,
    );
    setGlobalFontFamily(settings.fontFamily);
    updateGlobalOverrideRule();

    // Save settings to the web storage
    storage.set('panel-settings', settings);

    return;
  };
}
