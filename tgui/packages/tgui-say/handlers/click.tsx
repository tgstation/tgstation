import { Modal } from '../types';

/**
 * User clicks the channel button.
 * Simulates the tab key.
 */
// eslint-disable-next-line no-unused-vars
export const handleClick = function (this: Modal) {
	this.events.onIncrementChannel();
};
