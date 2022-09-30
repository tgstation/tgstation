import { Modal } from '../types';

/**
 * User clicks the channel button.
 * Simulates the tab key.
 */
export const handleClick = function (this: Modal) {
  this.events.onIncrementChannel();
};
