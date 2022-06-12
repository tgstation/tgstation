export { handleArrowKeys } from './arrowKeys';
export { handleBackspaceDelete } from './backspaceDelete';
export { handleComponentMount } from './componentMount';
export { handleEnter } from './enter';
export { handleForce } from './force';
export { handleIncrementChannel } from './incrementChannel';
export { handleKeyDown } from './keyDown';
export { handleRadioPrefix } from './radioPrefix';
export { handleReset } from './reset';
export { handleSetSize } from './setSize';
export { handleViewHistory } from './viewHistory';

/** Other handlers too small for their own file */
import { windowClose } from '../helpers';
import { TguiModal } from '../types';

/**
 * User clicks the channel button.
 * Simulates the tab key.
 */
export const handleClick = function (this: TguiModal) {
  this.onIncrementChannel();
};

/** User presses escape, closes the window */
export const handleEscape = function (this: TguiModal) {
  this.onReset();
  windowClose();
};

/**
 * Grabs input and sets size, force values etc.
 * Input value only triggers a rerender on setEdited.
 */
export const handleInput = function (this: TguiModal, _, value: string) {
  this.value = value;
  this.onRadioPrefix();
  this.onSetSize(value.length);
};

/** After updating the input value, sets back to false */
export const handleComponentUpdate = function (this: TguiModal) {
  this.setState({ edited: false });
};
