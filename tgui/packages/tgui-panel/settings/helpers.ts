/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { FONTS_DISABLED } from './constants';
import { setClientTheme } from './themes';
import type { SettingsState } from './types';

let statFontTimer: NodeJS.Timeout;
let statTabsTimer: NodeJS.Timeout;
let overrideRule: HTMLStyleElement;
let overrideFontFamily: string | undefined;
let overrideFontSize: string;

/** Updates the global CSS rule to override the font family and size. */
function updateGlobalOverrideRule(): void {
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
  fontSize: string | number,
  statFontSize: string | number,
  statLinked: boolean,
): void {
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

function setGlobalFontFamily(fontFamily: string): void {
  overrideFontFamily = fontFamily === FONTS_DISABLED ? undefined : fontFamily;
}

function setStatTabsStyle(style: string): void {
  clearInterval(statTabsTimer);
  Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  statTabsTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  }, 1500);
}

export function generalSettingsHandler(update: SettingsState): void {
  // Set client theme
  const theme = update?.theme;
  if (theme) {
    setClientTheme(theme);
  }

  // Update stat panel settings
  setStatTabsStyle(update.statTabsStyle);

  // Update global UI font size
  setGlobalFontSize(update.fontSize, update.statFontSize, update.statLinked);
  setGlobalFontFamily(update.fontFamily);
  updateGlobalOverrideRule();
}
