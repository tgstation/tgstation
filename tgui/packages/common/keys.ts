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
  Alt = 'Alt',
  Backspace = 'Backspace',
  Control = 'Control',
  Delete = 'Delete',
  Down = 'Down',
  End = 'End',
  Enter = 'Enter',
  Escape = 'Esc',
  Home = 'Home',
  Insert = 'Insert',
  Left = 'Left',
  PageDown = 'PageDown',
  PageUp = 'PageUp',
  Right = 'Right',
  Shift = 'Shift',
  Space = ' ',
  Tab = 'Tab',
  Up = 'Up',
}
