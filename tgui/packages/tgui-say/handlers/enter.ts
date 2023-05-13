import { Handlers } from '.';
import { windowClose } from '../helpers';
import { TguiSay } from '../TguiSay';

/** User presses enter. Closes if no value. */
export const handleEnter: Handlers['enter'] = function (
  this: TguiSay,
  event,
  value
) {
  const { chatHistory, channelIterator, maxLength, currentPrefix } =
    this.fields;
  const prefix = currentPrefix ?? '';

  event.preventDefault();

  if (value?.length < maxLength) {
    chatHistory.add(value);
    Byond.sendMessage('entry', {
      channel: channelIterator.current(),
      entry: channelIterator.isSay() ? prefix + value : value,
    });
  }

  this.handlers.reset();
  windowClose();
};
