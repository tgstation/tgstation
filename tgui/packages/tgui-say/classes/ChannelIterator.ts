type Channel = 'Say' | 'Radio' | 'Me' | 'OOC' | 'Admin';

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

  public set(channel: string): void {
    this.index = this.channels.indexOf(channel as Channel) || 0;
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

  public reset(): void {
    this.index = 0;
  }
}
