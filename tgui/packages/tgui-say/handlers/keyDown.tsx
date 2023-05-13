import { KEY } from 'common/keys';
import { Modal } from '../types';

const alphaRegex = /[a-zA-Z0-9]/;

/**
 * Handles other key events.
 * TAB - Changes channels.
 * UP/DOWN - Sets history counter and input value.
 * BKSP/DEL - Resets history counter and checks window size.
 * TYPING - When users key, it tells byond that it's typing.
 */
export const handleKeyDown: Modal['handlers']['keyDown'] = function (
  this: Modal,
  event
) {
  const { currentPrefix, channelIterator } = this.fields;

  if (!event.key) {
    return;
  }

  switch (event.key) {
    case KEY.Up:
    case KEY.Down:
      event.preventDefault();
      this.handlers.arrowKeys(event.key);
      break;

    case KEY.Tab:
      event.preventDefault();
      this.handlers.incrementChannel();
      break;

    case KEY.Delete:
    case KEY.Backspace:
      this.handlers.backspaceDelete();
      break;

    default:
      if (
        alphaRegex.test(event.key) &&
        channelIterator.isVisible() &&
        currentPrefix !== ':b '
      ) {
        this.timers.typingThrottle();
      }
  }
};
