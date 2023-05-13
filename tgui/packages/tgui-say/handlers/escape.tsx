import { windowClose } from '../helpers';
import { Modal } from '../types';

/** User presses escape, closes the window */
export const handleEscape: Modal['handlers']['escape'] = function (
  this: Modal
) {
  this.handlers.reset();
  windowClose();
};
