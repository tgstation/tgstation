import { CHANNELS } from '../constants';
import { Modal } from '../types';

// Insert the names of channels you want to not cycle on tab here
const BLACKLIST = ['Admin'];
const BLACKLISTED_CHANNEL_INDICES = CHANNELS.map((channel, index) => {
  if (BLACKLIST.includes(channel)) {
    return index;
  }
}).filter((x) => x !== undefined);

/**
 * Increments the channel or resets to the beginning of the list.
 * If the user switches between IC/OOC, messages Byond to toggle thinking
 * indicators.
 */
export const handleIncrementChannel = function (this: Modal) {
  let { channel } = this.state;
  const { currentPrefix } = this.fields;

  if (currentPrefix === ':b ') {
    this.timers.channelDebounce({ mode: true });
  }
  this.fields.currentPrefix = null;

  if (BLACKLISTED_CHANNEL_INDICES.includes(channel)) {
    return;
  }

  if (BLACKLISTED_CHANNEL_INDICES.length === CHANNELS.length) {
    this.setState({
      buttonContent: CHANNELS[channel],
      channel,
    });
    return;
  }

  for (let i = 0; i < CHANNELS.length; i++) {
    channel = (channel + 1) % CHANNELS.length;
    if (!BLACKLISTED_CHANNEL_INDICES.includes(channel)) {
      break;
    }
  }

  if (channel === CHANNELS.indexOf('OOC')) {
    // Disables thinking indicator for OOC channel
    this.timers.channelDebounce({ mode: false });
  }
  this.setState({
    buttonContent: CHANNELS[channel],
    channel,
  });
};
