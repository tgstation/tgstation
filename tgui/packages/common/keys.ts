/**
 * ### Key codes.
 * event.keyCode is deprecated, use this reference instead.
 *
 * Handles modifier keys (Shift, Alt, Control) and arrow keys.
 *
 * For alphabetical keys, use the actual character (e.g. 'a') instead of the key code.
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
 */
export enum KEY {
  Shift = 'Shift',
  Enter = 'Enter',
  Tab = 'Tab',
  Space = ' ',
  Down = 'ArrowDown',
  Up = 'ArrowUp',
  Left = 'ArrowLeft',
  Right = 'ArrowRight',
  Escape = 'Escape',
  Backspace = 'Backspace',
  Delete = 'Delete',
  Home = 'Home',
  End = 'End',
  PageUp = 'PageUp',
  PageDown = 'PageDown',
  Insert = 'Insert',
  Alt = 'Alt',
  Control = 'Control',
}
