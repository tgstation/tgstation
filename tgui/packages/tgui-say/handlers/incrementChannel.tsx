import { CHANNELS } from '../constants';
import { TguiModal } from '../types';

/**
 * Increments the channel or resets to the beginning of the list.
 * If the user switches between IC/OOC, messages Byond to toggle thinking
 * indicators.
 */
export const handleIncrementChannel = function (this: TguiModal) {
  const { channel } = this.state;
  const { radioPrefix } = this;
  if (radioPrefix === ':b ') {
    this.channelDebounce({ mode: true });
  }
  this.radioPrefix = '';
  if (channel === CHANNELS.length - 1) {
    this.channelDebounce({ mode: true });
    this.setState({
      buttonContent: CHANNELS[0],
      channel: 0,
    });
  } else {
    if (channel === 1) {
      this.channelDebounce({ mode: false });
    }
    this.setState({
      buttonContent: CHANNELS[channel + 1],
      channel: channel + 1,
    });
  }
};
