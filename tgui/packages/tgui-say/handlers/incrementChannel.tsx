import { CHANNELS } from '../constants';
import { Modal } from '../types';
// Insert the names of channels you want to not cycle on tab here
const BLACKLIST = ['Admin'];
const BLACKLISTED_CHANNELS = [] as number[];
CHANNELS.forEach((channel, index) => {
  if (BLACKLIST.includes(channel)) {
    BLACKLISTED_CHANNELS.push(index);
  }
});

/**
 * Increments the channel or resets to the beginning of the list.
 * If the user switches between IC/OOC, messages Byond to toggle thinking
 * indicators.
 */
export const handleIncrementChannel = function (this: Modal) {
  let { channel } = this.state;
  const { radioPrefix } = this.fields;
  if (radioPrefix === ':b ') {
    this.timers.channelDebounce({ mode: true });
  }
  this.fields.radioPrefix = '';
  if (BLACKLISTED_CHANNELS.includes(channel)) {
    return;
  }
  if (BLACKLISTED_CHANNELS.length === CHANNELS.length) {
    this.setState({
      buttonContent: CHANNELS[channel],
      channel: channel,
    });
    return;
  }
  do {
    channel++;
    if (channel === CHANNELS.length) {
      this.timers.channelDebounce({ mode: true });
      channel = 0;
    }
  } while (BLACKLISTED_CHANNELS.includes(channel));
  if (channel === CHANNELS.indexOf('OOC')) {
    // Disables thinking indicator for OOC channel
    this.timers.channelDebounce({ mode: false });
  }
  this.setState({
    buttonContent: CHANNELS[channel],
    channel: channel,
  });
};
