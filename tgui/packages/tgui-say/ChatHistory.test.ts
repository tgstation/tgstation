import { beforeEach, describe, expect, it } from 'bun:test';

import { ChatHistory } from './ChatHistory';

describe('ChatHistory', () => {
  let chatHistory: ChatHistory;

  beforeEach(() => {
    chatHistory = new ChatHistory();
  });

  it('should add a message to the history', () => {
    chatHistory.add('Hello');
    expect(chatHistory.getOlderMessage()).toEqual('Hello');
  });

  it('should retrieve older and newer messages', () => {
    chatHistory.add('Hello');
    chatHistory.add('World');
    expect(chatHistory.getOlderMessage()).toEqual('World');
    expect(chatHistory.getOlderMessage()).toEqual('Hello');
    expect(chatHistory.getNewerMessage()).toEqual('World');
    expect(chatHistory.getNewerMessage()).toBeNull();
    expect(chatHistory.getOlderMessage()).toEqual('World');
  });

  it('should limit the history to 5 messages', () => {
    for (let i = 1; i <= 6; i++) {
      chatHistory.add(`Message ${i}`);
    }

    expect(chatHistory.getOlderMessage()).toEqual('Message 6');
    for (let i = 5; i >= 2; i--) {
      expect(chatHistory.getOlderMessage()).toEqual(`Message ${i}`);
    }
    expect(chatHistory.getOlderMessage()).toBeNull();
  });

  it('should handle temp message correctly', () => {
    chatHistory.saveTemp('Temp message');
    expect(chatHistory.getTemp()).toEqual('Temp message');
    expect(chatHistory.getTemp()).toBeNull();
  });

  it('should reset correctly', () => {
    chatHistory.add('Hello');
    chatHistory.getOlderMessage();
    chatHistory.reset();
    expect(chatHistory.isAtLatest()).toBe(true);
    expect(chatHistory.getOlderMessage()).toEqual('Hello');
  });
});
