import { CHANNELS } from '../constants';
import { getHistoryAt, getHistoryLength } from '../helpers';
import { TguiModal } from '../types';

/**  Sets the input value to chat history at index historyCounter. */
export const handleViewHistory = function (this: TguiModal) {
  const { channel } = this.state;
  const { historyCounter } = this;
  if (historyCounter > 0 && getHistoryLength()) {
    this.value = getHistoryAt(historyCounter);
    if (channel < 2) {
      this.typingThrottle();
    }
    this.setState({ buttonContent: historyCounter, edited: true });
    this.onSetSize(0);
  } else {
    this.value = '';
    this.setState({
      buttonContent: CHANNELS[channel],
      edited: true,
    });
    this.onSetSize(0);
  }
};
