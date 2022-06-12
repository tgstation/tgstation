import { handleArrowKeys } from './arrowKeys';
import { handleBackspaceDelete } from './backspaceDelete';
import { handleComponentMount } from './componentMount';
import { handleEnter } from './enter';
import { handleForce } from './force';
import { windowClose } from '../helpers';
import { handleIncrementChannel } from './incrementChannel';
import { handleKeyDown } from './keyDown';
import { handleRadioPrefix } from './radioPrefix';
import { handleReset } from './reset';
import { handleSetSize } from './setSize';
import { TguiModal } from '../types';
import { handleViewHistory } from './viewHistory';

/**
 * User clicks the channel button.
 * Simulates the tab key.
 */
const handleClick = function (this: TguiModal) {
  this.events.onIncrementChannel();
};

/** User presses escape, closes the window */
const handleEscape = function (this: TguiModal) {
  this.events.onReset();
  windowClose();
};

/**
 * Grabs input and sets size, force values etc.
 * Input value only triggers a rerender on setEdited.
 */
const handleInput = function (this: TguiModal, _, value: string) {
  this.fields.value = value;
  this.events.onRadioPrefix();
  this.events.onSetSize(value.length);
};

/** After updating the input value, sets back to false */
const handleComponentUpdate = function (this: TguiModal) {
  this.setState({ edited: false });
};

export const handlers = {
  handleArrowKeys,
  handleBackspaceDelete,
  handleClick,
  handleComponentMount,
  handleComponentUpdate,
  handleEscape,
  handleEnter,
  handleForce,
  handleIncrementChannel,
  handleInput,
  handleKeyDown,
  handleRadioPrefix,
  handleReset,
  handleSetSize,
  handleViewHistory,
};
