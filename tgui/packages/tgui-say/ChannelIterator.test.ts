import { beforeEach, describe, it } from 'vitest';

import { ChannelIterator } from './ChannelIterator';

describe('ChannelIterator', () => {
  let channelIterator: ChannelIterator;

  beforeEach(() => {
    channelIterator = new ChannelIterator();
  });

  it('should cycle through channels properly', ({ expect }) => {
    expect(channelIterator.current()).toBe('Say');
    expect(channelIterator.next()).toBe('Radio');
    expect(channelIterator.next()).toBe('Me');
    // DOPPLER EDIT ADDITION START
    expect(channelIterator.next()).toBe('Whis');
    expect(channelIterator.next()).toBe('LOOC');
    expect(channelIterator.next()).toBe('Do');
    expect(channelIterator.next()).toBe('IRC');
    // DOPPLER EDIT ADDITION END
    expect(channelIterator.next()).toBe('OOC');
    expect(channelIterator.next()).toBe('Say'); // Admin is blacklisted so it should be skipped
  });

  it('should set a channel properly', ({ expect }) => {
    channelIterator.set('OOC');
    expect(channelIterator.current()).toBe('OOC');
  });

  it('should return true when current channel is "Say"', ({ expect }) => {
    channelIterator.set('Say');
    expect(channelIterator.isSay()).toBe(true);
  });

  it('should return false when current channel is not "Say"', ({ expect }) => {
    channelIterator.set('Radio');
    expect(channelIterator.isSay()).toBe(false);
  });

  it('should return true when current channel is visible', ({ expect }) => {
    channelIterator.set('Say');
    expect(channelIterator.isVisible()).toBe(true);
  });

  it('should return false when current channel is not visible', ({
    expect,
  }) => {
    channelIterator.set('OOC');
    expect(channelIterator.isVisible()).toBe(false);
  });

  it('should not leak a message from a blacklisted channel', ({ expect }) => {
    channelIterator.set('Admin');
    expect(channelIterator.next()).toBe('Admin');
  });
});
