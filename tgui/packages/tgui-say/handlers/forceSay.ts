import { Handlers } from '.';
import { WINDOW_SIZES } from '../constants';
import { windowSet } from '../helpers';
import { TguiSay } from '../TguiSay';

/** Sends the current input to byond and purges it */
export const handleForceSay: Handlers['forceSay'] = function (this: TguiSay) {
  const { channelIterator, currentPrefix, innerRef } = this.fields;
  const { reset } = this.handlers;
  const { size } = this.state;
  const { onForceSay } = this.timers;

  const currentValue = innerRef.current?.value;
  if (!currentValue || !channelIterator.isVisible()) return;

  onForceSay(
    channelIterator.isSay() ? currentPrefix + currentValue : currentValue
  );

  reset();

  if (size !== WINDOW_SIZES.small) {
    windowSet();
  }
};
