import { CHANNELS } from '../constants';
import { windowLoad, windowOpen } from '../helpers';
import { TguiModal } from '../types';

/** Attach listeners, sets window size just in case */
export const handleComponentMount = function (this: TguiModal) {
  Byond.subscribeTo('maxLength', (data) => {
    this.fields.maxLength = data.maxLength;
  });
  Byond.subscribeTo('force', () => {
    this.events.onForce();
  });
  Byond.subscribeTo('open', (data) => {
    const channel = CHANNELS.indexOf(data.channel) || 0;
    this.events.onReset(channel);
    setTimeout(() => {
      this.fields.innerRef.current?.focus();
    }, 1);
    windowOpen(CHANNELS[channel]);
  });
  windowLoad();
};
