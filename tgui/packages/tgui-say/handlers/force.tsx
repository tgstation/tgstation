import { CHANNELS, WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { TguiModal } from '../types';

/** Sends the current input to byond and purges it */
export const handleForce = function (this: TguiModal) {
  const { channel, size } = this.state;
  const { radioPrefix, value } = this;
  if (value && channel < 2) {
    this.forceDebounce({
      channel: CHANNELS[channel],
      entry: channel === 0 ? radioPrefix + value : value,
    });
    this.onReset(channel);
    if (size !== WINDOW_SIZES.small) {
      windowSet();
    }
  }
};
