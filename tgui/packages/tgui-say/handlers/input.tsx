import { Modal } from '../types';

/**
 * Grabs input and sets size, force values etc.
 * Input value only triggers a rerender on setEdited.
 */
export const handleInput = function (
  this: Modal,
  event: InputEvent,
  value: string
) {
  this.fields.currentValue = value;
  this.events.onRadioPrefix();
  this.events.onSetSize(value.length);
};
