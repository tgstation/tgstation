import { KEY_BACKSPACE, KEY_DELETE, KEY_DOWN, KEY_TAB, KEY_UP } from 'common/keycodes';
import { isAlphanumeric, getHistoryLength } from '../helpers';
import { TguiModal } from '../types';

/**
 * Handles other key events.
 * TAB - Changes channels.
 * UP/DOWN - Sets history counter and input value.
 * BKSP/DEL - Resets history counter and checks window size.
 * TYPING - When users key, it tells byond that it's typing.
 */
export const handleKeyDown = function (this: TguiModal, event: KeyboardEvent) {
  const { channel } = this.state;
  const { radioPrefix } = this;
  if (!event.keyCode) {
    return; // Really doubt it, but...
  }
  if (isAlphanumeric(event.keyCode)) {
    if (channel < 2 && radioPrefix !== ':b ') {
      this.typingThrottle();
    }
  }
  if (event.keyCode === KEY_UP || event.keyCode === KEY_DOWN) {
    if (getHistoryLength()) {
      this.onArrowKeys(event.keyCode);
    }
  }
  if (event.keyCode === KEY_DELETE || event.keyCode === KEY_BACKSPACE) {
    this.onBackspaceDelete();
  }
  if (event.keyCode === KEY_TAB) {
    this.onIncrementChannel();
    event.preventDefault();
  }
};
