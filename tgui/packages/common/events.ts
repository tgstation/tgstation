/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type Fn = (...args: any[]) => void;

export class EventEmitter {
  private listeners: Record<string, Fn[]>;

  constructor() {
    this.listeners = {};
  }

  on(name: string, listener: Fn): void {
    this.listeners[name] = this.listeners[name] || [];
    this.listeners[name].push(listener);
  }

  off(name: string, listener: Fn): void {
    const listeners = this.listeners[name];
    if (!listeners) {
      throw new Error(`There is no listeners for "${name}"`);
    }
    this.listeners[name] = listeners.filter((existingListener) => {
      return existingListener !== listener;
    });
  }

  emit(name: string, ...params: any[]): void {
    const listeners = this.listeners[name];
    if (!listeners) {
      return;
    }
    for (let i = 0, len = listeners.length; i < len; i += 1) {
      const listener = listeners[i];
      listener(...params);
    }
  }

  clear(): void {
    this.listeners = {};
  }
}
