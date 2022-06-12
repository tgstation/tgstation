import { CHANNELS } from '../constants';
import { TguiModal } from '../types';

/**
 * 1. Resets history if editing a message
 * 2. Backspacing while empty resets any radio subchannels
 * 3. Ensures backspace and delete calculate window size
 */
export const handleBackspaceDelete = function (this: TguiModal) {
  const { buttonContent, channel } = this.state;
  const { radioPrefix, value } = this;
  // User is on a chat history message
  if (typeof buttonContent === 'number') {
    this.historyCounter = 0;
    this.setState({ buttonContent: CHANNELS[channel] });
  }
  if (!value.length && radioPrefix) {
    this.radioPrefix = '';
    this.setState({ buttonContent: CHANNELS[channel] });
  }
  this.onSetSize(value.length);
};
