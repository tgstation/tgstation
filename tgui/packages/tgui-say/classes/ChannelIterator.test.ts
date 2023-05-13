import { ChannelIterator } from '../classes/ChannelIterator'; // Update this import path

describe('ChannelIterator', () => {
  let channelIterator: ChannelIterator;

  beforeEach(() => {
    channelIterator = new ChannelIterator();
  });

  it('should cycle through channels properly', () => {
    expect(channelIterator.current()).toBe('Say');
    expect(channelIterator.next()).toBe('Radio');
    expect(channelIterator.next()).toBe('Me');
    expect(channelIterator.next()).toBe('OOC');
    expect(channelIterator.next()).toBe('Say'); // Admin is blacklisted so it should be skipped
  });

  it('should set a channel properly', () => {
    channelIterator.set('OOC');
    expect(channelIterator.current()).toBe('OOC');
  });

  it('should return true when current channel is "Say"', () => {
    channelIterator.set('Say');
    expect(channelIterator.isSay()).toBe(true);
  });

  it('should return false when current channel is not "Say"', () => {
    channelIterator.set('Radio');
    expect(channelIterator.isSay()).toBe(false);
  });

  it('should return true when current channel is visible', () => {
    channelIterator.set('Say');
    expect(channelIterator.isVisible()).toBe(true);
  });

  it('should return false when current channel is not visible', () => {
    channelIterator.set('OOC');
    expect(channelIterator.isVisible()).toBe(false);
  });
});
