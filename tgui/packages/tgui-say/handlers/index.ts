import { KEY } from 'common/keys';
import { TguiSay } from '../TguiSay';
import { handleArrowKeys } from './arrowKeys';
import { handleBackspaceDelete } from './backspaceDelete';
import { handleComponentMount } from './componentMount';
import { handleEnter } from './enter';
import { handleEscape } from './escape';
import { handleForceSay } from './forceSay';
import { handleIncrementChannel } from './incrementChannel';
import { handleInput } from './input';
import { handleKeyDown } from './keyDown';
import { handleRadioPrefix } from './radioPrefix';
import { handleReset } from './reset';
import { handleSetSize } from './setSize';

export type Handlers = {
  arrowKeys: (direction: KEY.Up | KEY.Down) => void;
  backspaceDelete: () => void;
  componentMount: () => void;
  enter: (event: KeyboardEvent, value: string) => void;
  escape: () => void;
  forceSay: () => void;
  incrementChannel: () => void;
  input: (event: InputEvent, value: string) => void;
  keyDown: (event: KeyboardEvent, value: string) => void;
  radioPrefix: () => void;
  reset: () => void;
  setSize: (size: number) => void;
};

/**
 * Maps all TGUI say events with their associated handlers.
 */
export const mapEventHandlers = (parent: TguiSay) => {
  const handlers: Handlers = {
    arrowKeys: handleArrowKeys.bind(parent),
    backspaceDelete: handleBackspaceDelete.bind(parent),
    componentMount: handleComponentMount.bind(parent),
    enter: handleEnter.bind(parent),
    escape: handleEscape.bind(parent),
    forceSay: handleForceSay.bind(parent),
    incrementChannel: handleIncrementChannel.bind(parent),
    input: handleInput.bind(parent),
    keyDown: handleKeyDown.bind(parent),
    radioPrefix: handleRadioPrefix.bind(parent),
    reset: handleReset.bind(parent),
    setSize: handleSetSize.bind(parent),
  };

  return handlers;
};
