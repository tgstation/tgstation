import { CHANNELS } from '../constants';
import { Modal } from '../types';
const ADMIN_CHANNEL = CHANNELS.findIndex(
  (channel) => channel === 'Admin'
) as number;
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
  if (channel === ADMIN_CHANNEL) {
    this.setState({
      buttonContent: CHANNELS[channel],
      channel: channel,
    });
    return;
  }
  this.fields.radioPrefix = '';
  if (
    channel === CHANNELS.length - 1 ||
    (channel === ADMIN_CHANNEL - 1 && CHANNELS.length - 1 === ADMIN_CHANNEL)
  ) {
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
    if (
      channel === ADMIN_CHANNEL - 1 &&
      CHANNELS.length - 1 !== ADMIN_CHANNEL
    ) {
      this.setState({
        buttonContent: CHANNELS[channel + 2],
        channel: channel + 2,
      });
    } else {
      this.setState({
        buttonContent: CHANNELS[channel + 1],
        channel: channel + 1,
      });
    }
  }
};
