/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export class EventEmitter {
  constructor() {
    this.listeners = {};
  }

  on(name, listener) {
    this.listeners[name] = this.listeners[name] || [];
    this.listeners[name].push(listener);
  }

  off(name, listener) {
    const listeners = this.listeners[name];
    if (!listeners) {
      throw new Error(`There is no listeners for "${name}"`);
    }
    this.listeners[name] = listeners.filter((existingListener) => {
      return existingListener !== listener;
    });
  }

  emit(name, ...params) {
    const listeners = this.listeners[name];
    if (!listeners) {
      return;
    }
    for (let i = 0, len = listeners.length; i < len; i += 1) {
      const listener = listeners[i];
      listener(...params);
    }
  }

  clear() {
    this.listeners = {};
  }
}
