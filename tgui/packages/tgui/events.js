/**
 * Normalized browser focus events and BYOND-specific focus helpers.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { EventEmitter } from 'common/events';
import { KEY_ALT, KEY_CTRL, KEY_F1, KEY_F12, KEY_SHIFT } from 'common/keycodes';
import { logger } from './logging';

export const globalEvents = new EventEmitter();
let ignoreWindowFocus = false;

export const setupGlobalEvents = (options = {}) => {
  ignoreWindowFocus = !!options.ignoreWindowFocus;
};


// Window focus
// --------------------------------------------------------

let windowFocusTimeout;
let windowFocused = true;

const setWindowFocus = (value, delayed) => {
  // Pretend to always be in focus.
  if (ignoreWindowFocus) {
    windowFocused = true;
    return;
  }
  if (windowFocusTimeout) {
    clearTimeout(windowFocusTimeout);
    windowFocusTimeout = null;
  }
  if (delayed) {
    windowFocusTimeout = setTimeout(() => setWindowFocus(value));
    return;
  }
  if (windowFocused !== value) {
    // logger.log(window.__windowId__ + '/setWindowFocus', value);
    windowFocused = value;
    globalEvents.emit(value ? 'window-focus' : 'window-blur');
    globalEvents.emit('window-focus-change', value);
  }
};


// Focus stealing
// --------------------------------------------------------

let focusStolenBy = null;

export const canStealFocus = node => {
  const tag = String(node.tagName).toLowerCase();
  return tag === 'input' || tag === 'textarea';
};

const stealFocus = node => {
  releaseStolenFocus();
  focusStolenBy = node;
  focusStolenBy.addEventListener('blur', releaseStolenFocus);
};

const releaseStolenFocus = () => {
  if (focusStolenBy) {
    focusStolenBy.removeEventListener('blur', releaseStolenFocus);
    focusStolenBy = null;
  }
};


// Focus follows the mouse
// --------------------------------------------------------

let focusedNode = null;
let lastVisitedNode = null;
const trackedNodes = [];

export const addScrollableNode = node => {
  trackedNodes.push(node);
};

export const removeScrollableNode = node => {
  const index = trackedNodes.indexOf(node);
  if (index >= 0) {
    trackedNodes.splice(index, 1);
  }
};

const focusNearestTrackedParent = node => {
  if (focusStolenBy || !windowFocused) {
    return;
  }
  const body = document.body;
  while (node && node !== body) {
    if (trackedNodes.includes(node)) {
      if (focusedNode === node) {
        return;
      }
      // logger.log('focused tracked', node.className);
      focusedNode = node;
      node.focus();
      return;
    }
    node = node.parentNode;
  }
};

window.addEventListener('mousemove', e => {
  const node = e.target;
  if (node !== lastVisitedNode) {
    lastVisitedNode = node;
    focusNearestTrackedParent(node);
  }
});


// Focus event hooks
// --------------------------------------------------------

window.addEventListener('focusin', e => {
  // logger.log('window/focusin', e.target.tagName, e.target.className);
  lastVisitedNode = null;
  focusedNode = e.target;
  setWindowFocus(true);
  if (canStealFocus(e.target)) {
    stealFocus(e.target);
    return;
  }
});

window.addEventListener('focusout', e => {
  // logger.log('window/focusout', e.target.tagName, e.target.className);
  lastVisitedNode = null;
  setWindowFocus(false, true);
});

window.addEventListener('blur', e => {
  // logger.log('window/blur');
  lastVisitedNode = null;
  setWindowFocus(false, true);
});

window.addEventListener('beforeunload', e => {
  // logger.log('window/beforeunload');
  setWindowFocus(false);
});


// Key events
// --------------------------------------------------------

const keyHeldByCode = {};

class KeyEvent {
  constructor(e, type, repeat) {
    this.event = e;
    this.type = type;
    this.code = window.event ? e.which : e.keyCode;
    this.ctrl = e.ctrlKey;
    this.shift = e.shiftKey;
    this.alt = e.altKey;
    this.repeat = !!repeat;
  }

  hasModifierKeys() {
    return this.ctrl || this.alt || this.shift;
  }

  isModifierKey() {
    return this.code === KEY_CTRL
      || this.code === KEY_SHIFT
      || this.code === KEY_ALT;
  }

  isDown() {
    return this.type === 'keydown';
  }

  isUp() {
    return this.type === 'keyup';
  }

  toString() {
    if (this._str) {
      return this._str;
    }
    this._str = '';
    if (this.ctrl) {
      this._str += 'Ctrl+';
    }
    if (this.alt) {
      this._str += 'Alt+';
    }
    if (this.shift) {
      this._str += 'Shift+';
    }
    if (this.code >= 48 && this.code <= 90) {
      this._str += String.fromCharCode(this.code);
    }
    else if (this.code >= KEY_F1 && this.code <= KEY_F12) {
      this._str += 'F' + (this.code - 111);
    }
    else {
      this._str += '[' + this.code + ']';
    }
    return this._str;
  }
}

// IE8: Keydown event is only available on document.
document.addEventListener('keydown', e => {
  if (canStealFocus(e.target)) {
    return;
  }
  const code = e.keyCode;
  const key = new KeyEvent(e, 'keydown', keyHeldByCode[code]);
  globalEvents.emit('keydown', key);
  globalEvents.emit('key', key);
  keyHeldByCode[code] = true;
});

document.addEventListener('keyup', e => {
  if (canStealFocus(e.target)) {
    return;
  }
  const code = e.keyCode;
  const key = new KeyEvent(e, 'keyup');
  globalEvents.emit('keyup', key);
  globalEvents.emit('key', key);
  keyHeldByCode[code] = false;
});
