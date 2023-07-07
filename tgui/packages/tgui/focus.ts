/**
 * Various focus helpers.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Moves focus to the BYOND map window.
 */
export const focusMap = () => {
  Byond.winset('mapwindow.map', {
    focus: true,
  });
};

/**
 * Moves focus to the browser window.
 */
export const focusWindow = () => {
  Byond.winset(Byond.windowId, {
    focus: true,
  });
};
