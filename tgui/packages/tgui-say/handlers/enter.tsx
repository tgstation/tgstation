import { CHANNELS } from '../constants';
import { storeChat, windowClose } from '../helpers';
import { TguiModal } from '../types';

/** User presses enter. Closes if no value. */
export const handleEnter = function (
  this: TguiModal,
  event: KeyboardEvent,
  value: string
) {
  const { channel } = this.state;
  const { maxLength, radioPrefix } = this;
  event.preventDefault();
  if (value && value.length < maxLength) {
    storeChat(value);
    Byond.sendMessage('entry', {
      channel: CHANNELS[channel],
      entry: channel === 0 ? radioPrefix + value : value,
    });
  }
  this.onReset();
  windowClose();
};
