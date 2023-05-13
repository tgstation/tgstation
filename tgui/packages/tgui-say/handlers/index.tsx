import { handleArrowKeys } from './arrowKeys';
import { handleBackspaceDelete } from './backspaceDelete';
import { handleComponentMount } from './componentMount';
import { handleComponentUpdate } from './componentUpdate';
import { handleClick } from './click';
import { handleEnter } from './enter';
import { handleEscape } from './escape';
import { handleForceSay } from './force';
import { handleIncrementChannel } from './incrementChannel';
import { handleInput } from './input';
import { handleKeyDown } from './keyDown';
import { handleRadioPrefix } from './radioPrefix';
import { handleReset } from './reset';
import { handleSetSize } from './setSize';

import { Modal } from '../types';

/**
 * Maps all TGUI say events with their associated handlers.
 *
 * return -- object: events
 */
export const eventHandlerMap = (parent: Modal) => {
  const eventHandler: Modal['handlers'] = {
    arrowKeys: handleArrowKeys.bind(parent),
    backspaceDelete: handleBackspaceDelete.bind(parent),
    click: handleClick.bind(parent),
    componentMount: handleComponentMount.bind(parent),
    componentUpdate: handleComponentUpdate.bind(parent),
    enter: handleEnter.bind(parent),
    escape: handleEscape.bind(parent),
    forcesay: handleForceSay.bind(parent),
    incrementChannel: handleIncrementChannel.bind(parent),
    input: handleInput.bind(parent),
    keyDown: handleKeyDown.bind(parent),
    radioPrefix: handleRadioPrefix.bind(parent),
    reset: handleReset.bind(parent),
    setSize: handleSetSize.bind(parent),
  };

  return eventHandler;
};
