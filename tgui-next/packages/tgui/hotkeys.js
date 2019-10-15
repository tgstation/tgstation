import { createLogger } from './logging';

const logger = createLogger('hotkeys');

// Key codes
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
export const KEY_MINUS = 189;
export const KEY_EQUAL = 187;

const makeComboString = (ctrlKey, altKey, keyCode) => {
  const parts = [
    ctrlKey && 'Ctrl',
    altKey && 'Alt',
    '[' + keyCode + ']',
  ];
  return parts
    .filter(value => value)
    .join('+');
};

// Middleware
export const hotKeyMiddleware = store => {
  const { dispatch } = store;
  // Subscribe for hotkey events
  document.addEventListener('keyup', e => {
    const { ctrlKey, altKey } = e;
    const keyCode = window.event ? e.which : e.keyCode;
    // Dispatch them as store actions
    if (ctrlKey || altKey) {
      const comboString = makeComboString(ctrlKey, altKey, keyCode);
      logger.log(comboString);
      dispatch({
        type: 'hotKey',
        payload: { ctrlKey, altKey, keyCode },
      });
    }
  });
  // Pass through actions (do nothing)
  return next => action => next(action);
};

// Reducer
export const hotKeyReducer = (state, action) => {
  const { type, payload } = action;

  if (type === 'hotKey') {
    const { ctrlKey, altKey, keyCode } = payload;

    if (ctrlKey && altKey && keyCode === KEY_EQUAL) {
      // Toggle kitchen sink mode
      return {
        ...state,
        showKitchenSink: !state.showKitchenSink,
      };
    }

    return state;
  }

  return state;
};
