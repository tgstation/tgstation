import { windowClose } from '../helpers';
import { Modal } from '../types';

/** User presses enter. Closes if no value. */
export const handleEnter: Modal['handlers']['enter'] = function (
  this: Modal,
  event,
  value
) {
  const { chatHistory, channelIterator, maxLength, currentPrefix } =
    this.fields;

  event.preventDefault();

  if (value?.length < maxLength) {
    chatHistory.add(value);
    Byond.sendMessage('entry', {
      channel: channelIterator.current(),
      entry: channelIterator.isSay() ? currentPrefix + value : value,
    });
  }

  this.handlers.reset();
  windowClose();
};
