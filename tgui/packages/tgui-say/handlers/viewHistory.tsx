import { CHANNELS } from '../constants';
import { getHistoryAt, getHistoryLength } from '../helpers';
import { Modal } from '../types';

/**  Sets the input value to chat history at index historyCounter. */
export const handleViewHistory = function (this: Modal) {
  const { channel } = this.state;
  const { currentValue, historyCounter, tempHistory } = this.fields;

  if (historyCounter > 0 && getHistoryLength()) {
    this.fields.currentValue = getHistoryAt(historyCounter);

    if (channel < 2) {
      this.timers.typingThrottle();
    }

    this.setState({ buttonContent: historyCounter, edited: true });
  } else {
    /** Restores any saved history */
    this.fields.currentValue = tempHistory;
    this.fields.tempHistory = '';
    this.setState({
      buttonContent: CHANNELS[channel],
      edited: true,
    });
  }

  this.events.onSetSize(currentValue?.length || 0);
};
