import { CHANNELS } from '../constants';
import { windowLoad, windowOpen } from '../helpers';
import { TguiModal } from '../types';

/** Attach listeners, sets window size just in case */
export const handleComponentMount = function (this: TguiModal) {
  Byond.subscribeTo('maxLength', (data) => {
    this.maxLength = data.maxLength;
  });
  Byond.subscribeTo('force', () => {
    this.onForce();
  });
  Byond.subscribeTo('open', (data) => {
    const channel = CHANNELS.indexOf(data.channel) || 0;
    this.onReset(channel);
    setTimeout(() => {
      this.innerRef?.current?.focus();
    }, 1);
    windowOpen(CHANNELS[channel]);
  });
  windowLoad();
};
