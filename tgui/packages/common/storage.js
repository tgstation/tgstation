/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { getPrefCodebaseKey } from './config_setter';

export const IMPL_MEMORY = 0;
export const IMPL_LOCAL_STORAGE = 1;
export const IMPL_INDEXED_DB = 2;

const INDEXED_DB_VERSION = 1;
const INDEXED_DB_NAME = 'tgui';
const INDEXED_DB_STORE_NAME = 'storage-v1';

const READ_ONLY = 'readonly';
const READ_WRITE = 'readwrite';

const testGeneric = (testFn) => () => {
  try {
    return Boolean(testFn());
  } catch {
    return false;
  }
};

// Localstorage can sometimes throw an error, even if DOM storage is not
// disabled in IE11 settings.
// See: https://superuser.com/questions/1080011
// prettier-ignore
const testLocalStorage = testGeneric(() => (
  window.localStorage && window.localStorage.getItem
));

// prettier-ignore
const testIndexedDb = testGeneric(() => (
  (window.indexedDB || window.msIndexedDB)
  && (window.IDBTransaction || window.msIDBTransaction)
));

class MemoryBackend {
  constructor() {
    this.impl = IMPL_MEMORY;
    this.store = {};
  }

  get(key) {
    return this.store[key + this.get_noconfig(getPrefCodebaseKey())];
  }

  set(key, value) {
    this.store[key + this.get_noconfig(getPrefCodebaseKey())] = value;
  }

  remove(key) {
    this.store[key + this.get_noconfig(getPrefCodebaseKey())] = undefined;
  }

  clear() {
    this.store = {};
  }

  // these are 98% identical to things above
  get_noconfig(key) {
    return this.store[key];
  }

  set_noconfig(key, value) {
    this.store[key] = value;
  }

  remove_noconfig(key) {
    this.store[key] = undefined;
  }
}

class LocalStorageBackend {
  constructor() {
    this.impl = IMPL_LOCAL_STORAGE;
  }

  get(key) {
    const value = localStorage.getItem(
      key + this.get_noconfig(getPrefCodebaseKey())
    );
    if (typeof value === 'string') {
      return JSON.parse(value);
    }
  }

  set(key, value) {
    localStorage.setItem(
      key + this.get_noconfig(getPrefCodebaseKey()),
      JSON.stringify(value)
    );
  }

  remove(key) {
    localStorage.removeItem(key + this.get_noconfig(getPrefCodebaseKey()));
  }

  clear() {
    localStorage.clear();
  }

  // these are 98% identical to things above
  get_noconfig(key) {
    const value = localStorage.getItem(key);
    if (typeof value === 'string') {
      return JSON.parse(value);
    }
  }

  set_noconfig(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }

  remove_noconfig(key) {
    localStorage.removeItem(key);
  }
}

class IndexedDbBackend {
  constructor() {
    this.impl = IMPL_INDEXED_DB;
    /** @type {Promise<IDBDatabase>} */
    this.dbPromise = new Promise((resolve, reject) => {
      const indexedDB = window.indexedDB || window.msIndexedDB;
      const req = indexedDB.open(INDEXED_DB_NAME, INDEXED_DB_VERSION);
      req.onupgradeneeded = () => {
        try {
          req.result.createObjectStore(INDEXED_DB_STORE_NAME);
        } catch (err) {
          reject(new Error('Failed to upgrade IDB: ' + req.error));
        }
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => {
        reject(new Error('Failed to open IDB: ' + req.error));
      };
    });
  }

  getStore(mode) {
    // prettier-ignore
    return this.dbPromise.then((db) => db
      .transaction(INDEXED_DB_STORE_NAME, mode)
      .objectStore(INDEXED_DB_STORE_NAME));
  }

  async get(key) {
    const store = await this.getStore(READ_ONLY);
    return new Promise((resolve, reject) => {
      const req = store.get(key + this.get_noconfig(getPrefCodebaseKey()));
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }

  async set(key, value) {
    // The reason we don't _save_ null is because IE 10 does
    // not support saving the `null` type in IndexedDB. How
    // ironic, given the bug below!
    // See: https://github.com/mozilla/localForage/issues/161
    if (value === null) {
      value = undefined;
    }
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.put(value, key + this.get_noconfig(getPrefCodebaseKey()));
  }

  async remove(key) {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.delete(key + this.get_noconfig(getPrefCodebaseKey()));
  }

  async clear() {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.clear();
  }

  // these are 98% identical to things above
  async get_noconfig(key) {
    const store = await this.getStore(READ_ONLY);
    return new Promise((resolve, reject) => {
      const req = store.get(key);
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }

  async set_noconfig(key, value) {
    if (value === null) {
      value = undefined;
    }
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.put(value, key);
  }

  async remove_noconfig(key) {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.delete(key);
  }
}

/**
 * Web Storage Proxy object, which selects the best backend available
 * depending on the environment.
 */
class StorageProxy {
  constructor() {
    this.backendPromise = (async () => {
      if (testIndexedDb()) {
        try {
          const backend = new IndexedDbBackend();
          await backend.dbPromise;
          return backend;
        } catch {}
      }
      if (testLocalStorage()) {
        return new LocalStorageBackend();
      }
      return new MemoryBackend();
    })();
  }

  async get(key) {
    const backend = await this.backendPromise;
    return backend.get(key);
  }

  async set(key, value) {
    const backend = await this.backendPromise;
    return backend.set(key, value);
  }

  async remove(key) {
    const backend = await this.backendPromise;
    return backend.remove(key);
  }

  async clear() {
    const backend = await this.backendPromise;
    return backend.clear();
  }

  // these are identical to things above, but with config key.
  // this is why it is named `_noconfig`, not as camelCase, because it's 98% identical.
  async get_noconfig(key) {
    const backend = await this.backendPromise;
    return backend.get_noconfig(key);
  }

  async set_noconfig(key, value) {
    const backend = await this.backendPromise;
    return backend.set_noconfig(key, value);
  }

  async remove_noconfig(key) {
    const backend = await this.backendPromise;
    return backend.remove_noconfig(key);
  }
}

export const storage = new StorageProxy();
