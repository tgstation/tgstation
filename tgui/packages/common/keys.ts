/**
 * ### Key codes.
 * event.keyCode is deprecated, use this reference instead.
 *
 * Handles modifier keys (Shift, Alt, Control) and arrow keys.
 *
 * For alphabetical keys, use the actual character (e.g. 'a') instead of the key code.
 * Don't access Esc or Escape directly, use isEscape() instead
 *
 * Something isn't here that you want? Just add it:
 * @url https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values
 * @usage
 * ```ts
 * import { KEY } from 'tgui/common/keys';
 *
 * if (event.key === KEY.Enter) {
 *   // do something
 * }
 * ```
 *
 *
 */
export enum KEY {
  Alt = 'Alt',
  Backspace = 'Backspace',
  Control = 'Control',
  Delete = 'Delete',
  Down = 'ArrowDown',
  End = 'End',
  Enter = 'Enter',
  Esc = 'Esc',
  Escape = 'Escape',
  Home = 'Home',
  Insert = 'Insert',
  Left = 'ArrowLeft',
  PageDown = 'PageDown',
  PageUp = 'PageUp',
  Right = 'ArrowRight',
  Shift = 'Shift',
  Space = ' ',
  Tab = 'Tab',
  Up = 'ArrowUp',
}

/**
 * ### isEscape
 *
 * Checks if the user has hit the 'ESC' key on their keyboard.
 * There's a weirdness in BYOND where this could be either the string
 * 'Escape' or 'Esc' depending on the browser. This function handles
 * both cases.
 *
 * @param key - the key to check, typically from event.key
 * @returns true if key is Escape or Esc, false otherwise
 */
export function isEscape(key: string): boolean {
  return key === KEY.Esc || key === KEY.Escape;
}
