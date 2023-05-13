import { KEY } from 'common/keys';

import { Modal } from '../types';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys: Modal['handlers']['arrowKeys'] = function (
  this: Modal,
  direction
) {
  const { chatHistory, currentValue } = this.fields;

  if (direction === KEY.Up) {
    if (chatHistory.isAtLatest()) {
      // Save current message to temp history if at the most recent message
      chatHistory.saveTemp(currentValue);
    }
    // Try to get the previous message, fall back to the current value if none
    this.fields.currentValue = chatHistory.prev() ?? chatHistory.restoreTemp();
  } else {
    // Try to get the next message, fall back to the current value if none
    this.fields.currentValue = chatHistory.next() ?? currentValue;
  }

  this.setState({ edited: true });
};

/**
 * ### ChatHistory
 * A class to manage a chat history,
 * maintaining a maximum of five messages and supporting navigation,
 * temporary message storage, and query operations.
 */
export class ChatHistory {
  private messages: string[] = [];
  private index: number = -1;
  private tempMessage: string = '';

  public add(message: string): void {
    this.messages.unshift(message);
    if (this.messages.length > 5) {
      this.messages.pop();
    }
    this.index = -1; // Reset index when new message is added
    this.tempMessage = ''; // Clear temp message when a new message is added
  }

  public next(): string | null {
    if (this.index < 0 || this.index === this.messages.length - 1) {
      return null; // If we're at the "latest" state or there are no messages, return null
    }

    this.index++;
    return this.messages[this.index];
  }

  public prev(): string | null {
    if (this.messages.length === 0 || this.index <= 0) {
      return null; // If we're at the start of the history or there are no messages, return null
    }

    this.index--;
    return this.messages[this.index];
  }

  public get(): string | null {
    return this.index >= 0 && this.messages.length > 0
      ? this.messages[this.index]
      : null;
  }

  public reroll(): void {
    this.index = -1;
  }

  public saveTemp(message: string): void {
    this.tempMessage = message;
  }

  public restoreTemp(): string {
    return this.tempMessage;
  }

  public isAtLatest(): boolean {
    return this.index === -1;
  }
}
