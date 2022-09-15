import { CHANNELS } from '../constants';
import { Modal } from '../types';

/**
 * Increments the channel or resets to the beginning of the list.
 * If the user switches between IC/OOC, messages Byond to toggle thinking
 * indicators.
 */
export const handleIncrementChannel = function (this: Modal) {
  const { channel } = this.state;
  const { radioPrefix } = this.fields;
  if (radioPrefix === ':b ') {
    this.timers.channelDebounce({ mode: true });
  }
  this.fields.radioPrefix = '';
  if (channel === CHANNELS.length - 1) {
    this.timers.channelDebounce({ mode: true });
    this.setState({
      buttonContent: CHANNELS[0],
      channel: 0,
    });
  } else {
    if (channel === 2) {
      // Disables thinking indicator for OOC channel
      this.timers.channelDebounce({ mode: false });
    }
    this.setState({
      buttonContent: CHANNELS[channel + 1],
      channel: channel + 1,
    });
  }
};
