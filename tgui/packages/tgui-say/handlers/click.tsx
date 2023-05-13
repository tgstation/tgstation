import { Modal } from '../types';

/**
 * User clicks the channel button.
 * Simulates the tab key.
 */
export const handleClick: Modal['handlers']['click'] = function (this: Modal) {
  this.handlers.incrementChannel();
};
