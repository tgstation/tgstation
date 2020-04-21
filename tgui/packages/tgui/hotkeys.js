import { callByond, IS_IE8 } from './byond';
import { createLogger } from './logging';

const logger = createLogger('hotkeys');

// Key codes
export const KEY_BACKSPACE = 8;
export const KEY_TAB = 9;
export const KEY_ENTER = 13;
export const KEY_SHIFT = 16;
export const KEY_CTRL = 17;
export const KEY_ALT = 18;
export const KEY_ESCAPE = 27;
export const KEY_SPACE = 32;
export const KEY_0 = 48;
export const KEY_1 = 49;
export const KEY_2 = 50;
export const KEY_3 = 51;
export const KEY_4 = 52;
export const KEY_5 = 53;
export const KEY_6 = 54;
export const KEY_7 = 55;
export const KEY_8 = 56;
export const KEY_9 = 57;
export const KEY_A = 65;
export const KEY_B = 66;
export const KEY_C = 67;
export const KEY_D = 68;
export const KEY_E = 69;
export const KEY_F = 70;
export const KEY_G = 71;
export const KEY_H = 72;
export const KEY_I = 73;
export const KEY_J = 74;
export const KEY_K = 75;
export const KEY_L = 76;
export const KEY_M = 77;
export const KEY_N = 78;
export const KEY_O = 79;
export const KEY_P = 80;
export const KEY_Q = 81;
export const KEY_R = 82;
export const KEY_S = 83;
export const KEY_T = 84;
export const KEY_U = 85;
export const KEY_V = 86;
export const KEY_W = 87;
export const KEY_X = 88;
export const KEY_Y = 89;
export const KEY_Z = 90;
export const KEY_EQUAL = 187;
export const KEY_MINUS = 189;

const MODIFIER_KEYS = [
  KEY_CTRL,
  KEY_ALT,
  KEY_SHIFT,
];

const NO_PASSTHROUGH_KEYS = [
  KEY_ESCAPE,
  KEY_ENTER,
  KEY_SPACE,
  KEY_TAB,
  KEY_CTRL,
  KEY_SHIFT,
];

// Tracks the "pressed" state of keys
const keyState = {};

const createHotkeyString = (ctrlKey, altKey, shiftKey, keyCode) => {
  let str = '';
  if (ctrlKey) {
    str += 'Ctrl+';
  }
  if (altKey) {
    str += 'Alt+';
  }
  if (shiftKey) {
    str += 'Shift+';
  }
  if (keyCode >= 48 && keyCode <= 90) {
    str += String.fromCharCode(keyCode);
  }
  else {
    str += '[' + keyCode + ']';
  }
  return str;
};

/**
 * Parses the event and compiles information about the keypress.
 */
const getKeyData = e => {
  const keyCode = window.event ? e.which : e.keyCode;
  const { ctrlKey, altKey, shiftKey } = e;
  return {
    keyCode,
    ctrlKey,
    altKey,
    shiftKey,
    hasModifierKeys: ctrlKey || altKey || shiftKey,
    keyString: createHotkeyString(ctrlKey, altKey, shiftKey, keyCode),
  };
};

/**
 * Keyboard passthrough logic. This allows you to keep doing things
 * in game while the browser window is focused.
 */
const handlePassthrough = (e, eventType) => {
  if (e.defaultPrevented) {
    return;
  }
  const targetName = e.target && e.target.localName;
  if (targetName === 'input' || targetName === 'textarea') {
    return;
  }
  const keyData = getKeyData(e);
  const { keyCode, ctrlKey, shiftKey } = keyData;
  // NOTE: We pass through only Alt of all modifier keys, because Alt
  // modifier (for toggling run/walk) is implemented very shittily
  // in our codebase. We pass no other modifier keys, because they can
  // be used internally as tgui hotkeys.
  if (ctrlKey || shiftKey || NO_PASSTHROUGH_KEYS.includes(keyCode)) {
    return;
  }
  // Send this keypress to BYOND
  if (eventType === 'keydown' && !keyState[keyCode]) {
    logger.debug('passthrough', eventType, keyData);
    return callByond('', { __keydown: keyCode });
  }
  if (eventType === 'keyup' && keyState[keyCode]) {
    logger.debug('passthrough', eventType, keyData);
    return callByond('', { __keyup: keyCode });
  }
};

/**
 * Cleanup procedure for keyboard passthrough, which should be called
 * whenever you're unloading tgui.
 */
export const releaseHeldKeys = () => {
  for (let keyCode of Object.keys(keyState)) {
    if (keyState[keyCode]) {
      logger.log(`releasing [${keyCode}] key`);
      keyState[keyCode] = false;
      callByond('', { __keyup: keyCode });
    }
  }
};

const handleHotKey = (e, eventType, dispatch) => {
  if (eventType !== 'keyup') {
    return;
  }
  const keyData = getKeyData(e);
  const {
    ctrlKey,
    altKey,
    keyCode,
    hasModifierKeys,
    keyString,
  } = keyData;
  // Dispatch a detected hotkey as a store action
  if (hasModifierKeys && !MODIFIER_KEYS.includes(keyCode)) {
    logger.log(keyString);
    // Fun stuff
    if (ctrlKey && altKey && keyCode === KEY_BACKSPACE) {
      // NOTE: We need to call this in a timeout, because we need a clean
      // stack in order for this to be a fatal error.
      setTimeout(() => {
        throw new Error(
          'OOPSIE WOOPSIE!! UwU We made a fucky wucky!! A wittle'
          + ' fucko boingo! The code monkeys at our headquarters are'
          + ' working VEWY HAWD to fix this!');
      });
    }
    dispatch({
      type: 'hotKey',
      payload: keyData,
    });
  }
};

/**
 * Subscribe to an event when browser window has been completely
 * unfocused. Conveniently fires events when the browser window
 * is closed from the outside.
 */
const subscribeToLossOfFocus = listenerFn => {
  let timeout;
  document.addEventListener('focusout', () => {
    timeout = setTimeout(listenerFn);
  });
  document.addEventListener('focusin', () => {
    clearTimeout(timeout);
  });
  window.addEventListener('beforeunload', listenerFn);
};

/**
 * Subscribe to keydown/keyup events with globally tracked key state.
 */
const subscribeToKeyPresses = listenerFn => {
  document.addEventListener('keydown', e => {
    const keyCode = window.event ? e.which : e.keyCode;
    listenerFn(e, 'keydown');
    keyState[keyCode] = true;
  });
  document.addEventListener('keyup', e => {
    const keyCode = window.event ? e.which : e.keyCode;
    listenerFn(e, 'keyup');
    keyState[keyCode] = false;
  });
};

// Middleware
export const hotKeyMiddleware = store => {
  const { dispatch } = store;
  // Subscribe to key events
  subscribeToKeyPresses((e, eventType) => {
    // IE8: Can't determine the focused element, so by extension it passes
    // keypresses when inputs are focused.
    if (!IS_IE8) {
      handlePassthrough(e, eventType);
    }
    handleHotKey(e, eventType, dispatch);
  });
  // IE8: focusin/focusout only available on IE9+
  if (!IS_IE8) {
    // Clean up when browser window completely loses focus
    subscribeToLossOfFocus(() => {
      releaseHeldKeys();
    });
  }
  // Pass through store actions (do nothing)
  return next => action => next(action);
};

// Reducer
export const hotKeyReducer = (state, action) => {
  const { type, payload } = action;
  if (type === 'hotKey') {
    const { ctrlKey, altKey, keyCode } = payload;
    // Toggle kitchen sink mode
    if (ctrlKey && altKey && keyCode === KEY_EQUAL) {
      return {
        ...state,
        showKitchenSink: !state.showKitchenSink,
      };
    }
    // Toggle layout debugger
    if (ctrlKey && altKey && keyCode === KEY_MINUS) {
      return {
        ...state,
        debugLayout: !state.debugLayout,
      };
    }
    return state;
  }
  return state;
};
