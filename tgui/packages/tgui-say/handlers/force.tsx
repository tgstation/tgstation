import { CHANNELS, WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { Modal } from '../types';

/** Sends the current input to byond and purges it */
export const handleForce = function (this: Modal) {
  const { channel, size } = this.state;
  const { radioPrefix, value } = this.fields;
  if (value && channel < 2) {
    this.timers.forceDebounce({
      channel: CHANNELS[channel],
      entry: channel === 0 ? radioPrefix + value : value,
    });
    this.events.onReset(channel);
    if (size !== WINDOW_SIZES.small) {
      windowSet();
    }
  }
};
