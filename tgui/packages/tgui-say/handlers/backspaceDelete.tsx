import { Modal } from '../types';

/**
 * 1. Resets history if editing a message
 * 2. Backspacing while empty resets any radio subchannels
 * 3. Ensures backspace and delete calculate window size
 */
export const handleBackspaceDelete: Modal['handlers']['backspaceDelete'] =
  function (this: Modal) {
    const { buttonContent } = this.state;
    const { channelIterator, currentPrefix, chatHistory, currentValue } =
      this.fields;

    // User is on a chat history message
    if (typeof buttonContent === 'number') {
      chatHistory.reroll();
      this.setState({ buttonContent: channelIterator.current() });
    }

    if (!currentValue?.length && currentPrefix) {
      this.fields.currentPrefix = null;
      this.setState({ buttonContent: channelIterator.current() });
    }

    this.handlers.setSize(currentValue?.length);
  };
