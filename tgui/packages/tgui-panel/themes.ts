/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark'];

const COLORS = {
  DARK: {
    BG_BASE: '#202020',
    BG_SECOND: '#171717',
    BUTTON: '#494949',
    TEXT: '#A4BAD6',
  },
  LIGHT: {
    BG_BASE: '#EEEEEE',
    BG_SECOND: '#FFFFFF',
    BUTTON: 'none',
    TEXT: '#000000',
  },
};

let setClientThemeTimer: NodeJS.Timeout;

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export const setClientTheme = (name) => {
  // Transmit once for fast updates and again in a little while in case we won
  // the race against statbrowser init.
  clearInterval(setClientThemeTimer);
  Byond.command(`.output statbrowser:set_theme ${name}`);
  setClientThemeTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_theme ${name}`);
  }, 1500);

  const themeColor = COLORS[name.toUpperCase()];
  if (!themeColor) {
    return;
  }

  return Byond.winset({
    // Main windows
    'infowindow.background-color': themeColor.BG_BASE,
    'infowindow.text-color': themeColor.TEXT,
    'info.background-color': themeColor.BG_BASE,
    'info.text-color': themeColor.TEXT,
    'browseroutput.background-color': themeColor.BG_BASE,
    'browseroutput.text-color': themeColor.TEXT,
    'outputwindow.background-color': themeColor.BG_BASE,
    'outputwindow.text-color': themeColor.TEXT,
    'mainwindow.background-color': themeColor.BG_BASE,
    'split.background-color': themeColor.BG_BASE,
    // Buttons
    'changelog.background-color': themeColor.BUTTON,
    'changelog.text-color': themeColor.TEXT,
    'rules.background-color': themeColor.BUTTON,
    'rules.text-color': themeColor.TEXT,
    'wiki.background-color': themeColor.BUTTON,
    'wiki.text-color': themeColor.TEXT,
    'forum.background-color': themeColor.BUTTON,
    'forum.text-color': themeColor.TEXT,
    'github.background-color': themeColor.BUTTON,
    'github.text-color': themeColor.TEXT,
    'report-issue.background-color': themeColor.BUTTON,
    'report-issue.text-color': themeColor.TEXT,
    'fullscreen-toggle.background-color': themeColor.BUTTON,
    'fullscreen-toggle.text-color': themeColor.TEXT,
    // Status and verb tabs
    'output.background-color': themeColor.BG_BASE,
    'output.text-color': themeColor.TEXT,
    // Say, OOC, me Buttons etc.
    'saybutton.background-color': themeColor.BG_BASE,
    'saybutton.text-color': themeColor.TEXT,
    'oocbutton.background-color': themeColor.BG_BASE,
    'oocbutton.text-color': themeColor.TEXT,
    'mebutton.background-color': themeColor.BG_BASE,
    'mebutton.text-color': themeColor.TEXT,
    'asset_cache_browser.background-color': themeColor.BG_BASE,
    'asset_cache_browser.text-color': themeColor.TEXT,
    'tooltip.background-color': themeColor.BG_BASE,
    'tooltip.text-color': themeColor.TEXT,
    'input.background-color': themeColor.BG_SECOND,
    'input.text-color': themeColor.TEXT,
  });
};
