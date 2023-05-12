import { KEY_BACKSPACE, KEY_DELETE, KEY_DOWN, KEY_TAB, KEY_UP } from 'common/keycodes';
import { isAlphanumeric } from '../helpers';
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
  const { currentPrefix } = this.fields;

  if (!event.keyCode) {
    return;
  }

  switch (event.keyCode) {
    case KEY_UP:
    case KEY_DOWN:
      event.preventDefault();
      this.events.onArrowKeys(event.keyCode);
      break;

    case KEY_TAB:
      event.preventDefault();
      this.events.onIncrementChannel();
      break;

    case KEY_DELETE:
    case KEY_BACKSPACE:
      this.events.onBackspaceDelete();
      break;

    default:
      if (
        isAlphanumeric(event.keyCode) &&
        channel !== 3 &&
        currentPrefix !== ':b '
      ) {
        this.timers.typingThrottle();
      }
      break;
  }
};
