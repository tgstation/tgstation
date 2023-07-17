/**
 * ### ChatHistory
 * A class to manage a chat history,
 * maintaining a maximum of five messages and supporting navigation,
 * temporary message storage, and query operations.
 */
export class ChatHistory {
  private messages: string[] = [];
  private index: number = -1; // Initialize index at -1
  private temp: string | null = null;

  public add(message: string): void {
    this.messages.unshift(message);
    this.index = -1; // Reset index
    if (this.messages.length > 5) {
      this.messages.pop();
    }
  }

  public getIndex(): number {
    return this.index + 1;
  }

  public getOlderMessage(): string | null {
    if (this.messages.length === 0 || this.index >= this.messages.length - 1) {
      return null;
    }
    this.index++;
    return this.messages[this.index];
  }

  public getNewerMessage(): string | null {
    if (this.index <= 0) {
      this.index = -1;
      return null;
    }
    this.index--;
    return this.messages[this.index];
  }

  public isAtLatest(): boolean {
    return this.index === -1;
  }

  public saveTemp(message: string): void {
    this.temp = message;
  }

  public getTemp(): string | null {
    const temp = this.temp;
    this.temp = null;
    return temp;
  }

  public reset(): void {
    this.index = -1;
    this.temp = null;
  }
}
