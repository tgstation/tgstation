import { KEY_BACKSPACE, KEY_DELETE, KEY_DOWN, KEY_TAB, KEY_UP } from 'common/keycodes';
import { isAlphanumeric, getHistoryLength } from '../helpers';
import { Modal } from '../types';

/**
 * Handles other key events.
 * TAB - Changes channels.
 * UP/DOWN - Sets history counter and input value.
 * BKSP/DEL - Resets history counter and checks window size.
 * TYPING - When users key, it tells byond that it's typing.
 */
export const handleKeyDown = function (this: Modal, event: KeyboardEvent) {
  const { channel } = this.state;
  const { radioPrefix } = this.fields;
  if (!event.keyCode) {
    return; // Really doubt it, but...
  }
  if (isAlphanumeric(event.keyCode)) {
    if (channel !== 3 && radioPrefix !== ':b ') {
      this.timers.typingThrottle();
    }
  }
  if (event.keyCode === KEY_UP || event.keyCode === KEY_DOWN) {
    if (getHistoryLength()) {
      this.events.onArrowKeys(event.keyCode);
    }
  }
  if (event.keyCode === KEY_DELETE || event.keyCode === KEY_BACKSPACE) {
    this.events.onBackspaceDelete();
  }
  if (event.keyCode === KEY_TAB) {
    this.events.onIncrementChannel();
    event.preventDefault();
  }
};
