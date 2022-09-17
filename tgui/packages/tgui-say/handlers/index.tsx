import { handleArrowKeys } from './arrowKeys';
import { handleBackspaceDelete } from './backspaceDelete';
import { handleComponentMount } from './componentMount';
import { handleComponentUpdate } from './componentUpdate';
import { handleClick } from './click';
import { handleEnter } from './enter';
import { handleEscape } from './escape';
import { handleForce } from './force';
import { handleIncrementChannel } from './incrementChannel';
import { handleInput } from './input';
import { handleKeyDown } from './keyDown';
import { handleRadioPrefix } from './radioPrefix';
import { handleReset } from './reset';
import { handleSetSize } from './setSize';
import { handleViewHistory } from './viewHistory';
import { Modal } from '../types';

/**
 * Maps all TGUI say events with their associated handlers.
 *
 * return -- object: events
 */
export const eventHandlerMap = (parent: Modal): Modal['events'] => {
  return {
    onArrowKeys: handleArrowKeys.bind(parent),
    onBackspaceDelete: handleBackspaceDelete.bind(parent),
    onClick: handleClick.bind(parent),
    onComponentMount: handleComponentMount.bind(parent),
    onComponentUpdate: handleComponentUpdate.bind(parent),
    onEnter: handleEnter.bind(parent),
    onEscape: handleEscape.bind(parent),
    onForce: handleForce.bind(parent),
    onIncrementChannel: handleIncrementChannel.bind(parent),
    onInput: handleInput.bind(parent),
    onKeyDown: handleKeyDown.bind(parent),
    onRadioPrefix: handleRadioPrefix.bind(parent),
    onReset: handleReset.bind(parent),
    onSetSize: handleSetSize.bind(parent),
    onViewHistory: handleViewHistory.bind(parent),
  };
};
