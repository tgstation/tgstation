import { Modal } from '../types';

type Channel = 'Say' | 'Radio' | 'Me' | 'OOC' | 'Admin';

/**
 * Increments the channel or resets to the beginning of the list.
 * If the user switches between IC/OOC, messages Byond to toggle thinking
 * indicators.
 */
export const handleIncrementChannel: Modal['handlers']['incrementChannel'] =
  function (this: Modal) {
    const { currentPrefix, channelIterator } = this.fields;

    if (currentPrefix === ':b ') {
      this.timers.channelDebounce({ visible: true });
    }
    this.fields.currentPrefix = null;

    channelIterator.next();

    if (!channelIterator.isVisible()) {
      // Disables thinking indicator for OOC channel
      this.timers.channelDebounce({ visible: false });
    }

    this.setState({
      buttonContent: channelIterator.current(),
    });
  };

/**
 * ### ChannelIterator
 * Cycles a predefined list of channels,
 * skipping over blacklisted ones,
 * and providing methods to manage and query the current channel.
 */
export class ChannelIterator {
  private index: number = 0;
  private readonly channels: Channel[] = ['Say', 'Radio', 'Me', 'OOC', 'Admin'];
  private readonly blacklist: Channel[] = ['Admin'];
  private readonly quiet: Channel[] = ['OOC', 'Admin'];

  public next(): Channel {
    do {
      this.index = (this.index + 1) % this.channels.length;
    } while (this.blacklist.includes(this.channels[this.index]));

    return this.channels[this.index];
  }

  public get(channel: number): Channel {
    return this.channels[channel];
  }

  public set(channel: number): void {
    this.index = channel;
  }

  public current(): Channel {
    return this.channels[this.index];
  }

  public isSay(): boolean {
    return this.channels[this.index] === 'Say';
  }

  public isVisible(): boolean {
    return !this.quiet.includes(this.channels[this.index]);
  }
}
