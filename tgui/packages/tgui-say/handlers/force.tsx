import { WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { Modal } from '../types';

/** Sends the current input to byond and purges it */
export const handleForceSay: Modal['handlers']['forcesay'] = function (
  this: Modal
) {
  const { size } = this.state;
  const { channelIterator, currentPrefix, currentValue } = this.fields;

  if (!currentValue || !channelIterator.isVisible()) return;

  this.timers.forceDebounce({
    channel: channelIterator.current(),
    entry: channelIterator.isSay()
      ? currentPrefix + currentValue
      : currentValue,
  });

  this.handlers.reset();

  if (size !== WINDOW_SIZES.small) {
    windowSet();
  }
};
