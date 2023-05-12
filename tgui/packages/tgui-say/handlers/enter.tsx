import { CHANNELS } from '../constants';
import { storeChat, windowClose } from '../helpers';
import { Modal } from '../types';

/** User presses enter. Closes if no value. */
export const handleEnter = function (
  this: Modal,
  event: KeyboardEvent,
  value: string
) {
  const { channel } = this.state;
  const { maxLength, currentPrefix } = this.fields;

  event.preventDefault();

  if (value?.length < maxLength) {
    storeChat(value);
    Byond.sendMessage('entry', {
      channel: CHANNELS[channel],
      entry: channel === 0 ? currentPrefix + value : value,
    });
  }

  this.events.onReset();
  windowClose();
};
