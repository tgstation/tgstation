/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { KEY_CTRL, KEY_ENTER, KEY_ESCAPE, KEY_F, KEY_F5, KEY_R, KEY_SHIFT, KEY_SPACE, KEY_TAB } from 'common/keycodes';
import { globalEvents } from './events';
import { createLogger } from './logging';

const logger = createLogger('hotkeys');

// BYOND macros, in `key: command` format.
const byondMacros = {};

// Array of acquired keys, which will not be sent to BYOND.
const hotKeysAcquired = [
  // Default set of acquired keys
  KEY_ESCAPE,
  KEY_ENTER,
  KEY_SPACE,
  KEY_TAB,
  KEY_CTRL,
  KEY_SHIFT,
  KEY_F5,
];

// State of passed-through keys.
const keyState = {};

/**
 * Converts a browser keycode to BYOND keycode.
 */
const keyCodeToByond = keyCode => {
  if (keyCode === 16) return 'Shift';
  if (keyCode === 17) return 'Ctrl';
  if (keyCode === 18) return 'Alt';
  if (keyCode === 33) return 'Northeast';
  if (keyCode === 34) return 'Southeast';
  if (keyCode === 35) return 'Southwest';
  if (keyCode === 36) return 'Northwest';
  if (keyCode === 37) return 'West';
  if (keyCode === 38) return 'North';
  if (keyCode === 39) return 'East';
  if (keyCode === 40) return 'South';
  if (keyCode === 45) return 'Insert';
  if (keyCode === 46) return 'Delete';
  if (keyCode >= 48 && keyCode <= 57 || keyCode >= 65 && keyCode <= 90) {
    return String.fromCharCode(keyCode);
  }
  if (keyCode >= 96 && keyCode <= 105) {
    return 'Numpad' + (keyCode - 96);
  }
  if (keyCode >= 112 && keyCode <= 123) {
    return 'F' + (keyCode - 111);
  }
  if (keyCode === 188) return ',';
  if (keyCode === 189) return '-';
  if (keyCode === 190) return '.';
};

/**
 * Keyboard passthrough logic. This allows you to keep doing things
 * in game while the browser window is focused.
 */
const handlePassthrough = key => {
  // In addition to F5, support reloading with Ctrl+R and Ctrl+F5
  if (key.ctrl && (key.code === KEY_F5 || key.code === KEY_R)) {
    location.reload();
    return;
  }
  // Prevent passthrough on Ctrl+F
  if (key.ctrl && key.code === KEY_F) {
    return;
  }
  // NOTE: Alt modifier is pretty bad and sticky in IE11.
  if (key.event.defaultPrevented
      || key.isModifierKey()
      || hotKeysAcquired.includes(key.code)) {
    return;
  }
  const byondKeyCode = keyCodeToByond(key.code);
  if (!byondKeyCode) {
    return;
  }
  // Macro
  const macro = byondMacros[byondKeyCode];
  if (macro) {
    logger.debug('macro', macro);
    return Byond.command(macro);
  }
  // KeyDown
  if (key.isDown() && !keyState[byondKeyCode]) {
    keyState[byondKeyCode] = true;
    const command = `KeyDown "${byondKeyCode}"`;
    logger.debug(command);
    return Byond.command(command);
  }
  // KeyUp
  if (key.isUp() && keyState[byondKeyCode]) {
    keyState[byondKeyCode] = false;
    const command = `KeyUp "${byondKeyCode}"`;
    logger.debug(command);
    return Byond.command(command);
  }
};

/**
 * Acquires a lock on the hotkey, which prevents it from being
 * passed through to BYOND.
 */
export const acquireHotKey = keyCode => {
  hotKeysAcquired.push(keyCode);
};

/**
 * Makes the hotkey available to BYOND again.
 */
export const releaseHotKey = keyCode => {
  const index = hotKeysAcquired.indexOf(keyCode);
  if (index >= 0) {
    hotKeysAcquired.splice(index, 1);
  }
};

export const releaseHeldKeys = () => {
  for (let byondKeyCode of Object.keys(keyState)) {
    if (keyState[byondKeyCode]) {
      keyState[byondKeyCode] = false;
      logger.log(`releasing key "${byondKeyCode}"`);
      Byond.command(`KeyUp "${byondKeyCode}"`);
    }
  }
};

export const setupHotKeys = () => {
  // Read macros
  Byond.winget('default.*').then(data => {
    // Group each macro by ref
    const groupedByRef = {};
    for (let key of Object.keys(data)) {
      const keyPath = key.split('.');
      const ref = keyPath[1];
      const prop = keyPath[2];
      if (ref && prop) {
        if (!groupedByRef[ref]) {
          groupedByRef[ref] = {};
        }
        groupedByRef[ref][prop] = data[key];
      }
    }
    // Insert macros
    const escapedQuotRegex = /\\"/g;
    const unescape = str => str
      .substring(1, str.length - 1)
      .replace(escapedQuotRegex, '"');
    for (let ref of Object.keys(groupedByRef)) {
      const macro = groupedByRef[ref];
      const byondKeyName = unescape(macro.name);
      byondMacros[byondKeyName] = unescape(macro.command);
    }
    logger.debug('loaded macros', byondMacros);
  });
  // Setup event handlers
  globalEvents.on('window-blur', () => {
    releaseHeldKeys();
  });
  globalEvents.on('key', key => {
    handlePassthrough(key);
  });
};
