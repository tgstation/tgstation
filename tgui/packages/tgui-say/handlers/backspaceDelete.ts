import { Handlers } from '.';
import { TguiSay } from '../TguiSay';

/**
 * 1. Resets history if editing a message
 * 2. Backspacing while empty resets any radio subchannels
 * 3. Ensures backspace and delete calculate window size
 */
export const handleBackspaceDelete: Handlers['backspaceDelete'] = function (
  this: TguiSay
) {
  const { channelIterator, currentPrefix, chatHistory, innerRef } = this.fields;
  const { buttonContent } = this.state;
  const { setSize } = this.handlers;
  const currentValue = innerRef.current?.value;

  // User is on a chat history message
  if (typeof buttonContent === 'number') {
    chatHistory.reset();
    this.setState({ buttonContent: channelIterator.current() });
  }

  if (!currentValue) {
    return;
  }

  if (currentPrefix) {
    this.fields.currentPrefix = null;
    this.setState({ buttonContent: channelIterator.current() });
  }
  setSize(currentValue?.length);
};
