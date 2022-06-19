import { windowClose } from '../helpers';
import { Modal } from '../types';

/** User presses escape, closes the window */
// eslint-disable-next-line no-unused-vars
export const handleEscape = function (this: Modal) {
	this.events.onReset();
	windowClose();
};
