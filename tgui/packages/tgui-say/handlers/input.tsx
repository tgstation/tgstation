import { Modal } from '../types';

/**
 * Grabs input and sets size, force values etc.
 * Input value only triggers a rerender on setEdited.
 */
export const handleInput: Modal['handlers']['input'] = function (
  this: Modal,
  event,
  value
) {
  this.fields.currentValue = value;
  this.handlers.radioPrefix();
  this.handlers.setSize(value.length);
};
