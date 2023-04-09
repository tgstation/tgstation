import { CHANNELS } from '../constants';
import { windowLoad, windowOpen } from '../helpers';
import { Modal } from '../types';

/** Attach listeners, sets window size just in case */
export const handleComponentMount = function (this: Modal) {
  Byond.subscribeTo('props', (data) => {
    this.fields.maxLength = data.maxLength;
    this.fields.lightMode = !!data.lightMode;
  });
  Byond.subscribeTo('force', () => {
    this.events.onForce();
  });
  Byond.subscribeTo('open', (data) => {
    const channel = CHANNELS.indexOf(data.channel) || 0;
    this.setState({ buttonContent: CHANNELS[channel], channel });
    setTimeout(() => {
      this.fields.innerRef.current?.focus();
    }, 1);
    windowOpen(CHANNELS[channel]);
  });
  windowLoad();
};
