import { windowClose } from '../helpers';
import { Modal } from '../types';

/** User presses escape, closes the window */
export const handleEscape = function (this: Modal) {
  this.events.onReset();
  windowClose();
};
