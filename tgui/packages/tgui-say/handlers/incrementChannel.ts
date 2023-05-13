import { Handlers } from '.';
import { TguiSay } from '../TguiSay';

/**
 * Increments the channel or resets to the beginning of the list.
 * If the user switches between IC/OOC, messages Byond to toggle thinking
 * indicators.
 */
export const handleIncrementChannel: Handlers['incrementChannel'] = function (
  this: TguiSay
) {
  const { channelIterator, currentPrefix } = this.fields;
  const { onChannelIncrement } = this.timers;

  if (channelIterator.isSay() && currentPrefix === ':b ') {
    this.timers.onChannelIncrement(true);
  }

  this.fields.currentPrefix = null;

  channelIterator.next();

  // If we've looped onto a quiet channel, tell byond to hide thinking indicators
  if (!channelIterator.isVisible()) {
    onChannelIncrement(false);
  }

  this.setState({
    buttonContent: channelIterator.current(),
  });
};
