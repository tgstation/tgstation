/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const IMPL_MEMORY = 0;
export const IMPL_HUB_STORAGE = 1;
export const IMPL_INDEXED_DB = 2;

type StorageImplementation =
  | typeof IMPL_MEMORY
  | typeof IMPL_HUB_STORAGE
  | typeof IMPL_INDEXED_DB;

const INDEXED_DB_VERSION = 1;
const INDEXED_DB_NAME = 'tgui';
const INDEXED_DB_STORE_NAME = 'storage-v1';

const READ_ONLY = 'readonly';
const READ_WRITE = 'readwrite';

type StorageBackend = {
  impl: StorageImplementation;
  get(key: string): Promise<any>;
  set(key: string, value: any): Promise<void>;
  remove(key: string): Promise<void>;
  clear(): Promise<void>;
};

const testGeneric = (testFn: () => boolean) => (): boolean => {
  try {
    return Boolean(testFn());
  } catch {
    return false;
  }
};

const testHubStorage = testGeneric(
  () => window.hubStorage && !!window.hubStorage.getItem,
);

// TODO: Remove with 516
// prettier-ignore
const testIndexedDb = testGeneric(() => (
  (window.indexedDB || window.msIndexedDB)
  && !!(window.IDBTransaction || window.msIDBTransaction)
));

class MemoryBackend implements StorageBackend {
  private store: Record<string, any>;
  public impl: StorageImplementation;

  constructor() {
    this.impl = IMPL_MEMORY;
    this.store = {};
  }

  async get(key: string): Promise<any> {
    return this.store[key];
  }

  async set(key: string, value: any): Promise<void> {
    this.store[key] = value;
  }

  async remove(key: string): Promise<void> {
    this.store[key] = undefined;
  }

  async clear(): Promise<void> {
    this.store = {};
  }
}

class HubStorageBackend implements StorageBackend {
  public impl: StorageImplementation;

  constructor() {
    this.impl = IMPL_HUB_STORAGE;
  }

  async get(key: string): Promise<any> {
    const value = await window.hubStorage.getItem(key);
    if (typeof value === 'string') {
      return JSON.parse(value);
    }
    return undefined;
  }

  async set(key: string, value: any): Promise<void> {
    window.hubStorage.setItem(key, JSON.stringify(value));
  }

  async remove(key: string): Promise<void> {
    window.hubStorage.removeItem(key);
  }

  async clear(): Promise<void> {
    window.hubStorage.clear();
  }
}

class IndexedDbBackend implements StorageBackend {
  public impl: StorageImplementation;
  public dbPromise: Promise<IDBDatabase>;

  constructor() {
    this.impl = IMPL_INDEXED_DB;
    this.dbPromise = new Promise((resolve, reject) => {
      const indexedDB = window.indexedDB || window.msIndexedDB;
      const req = indexedDB.open(INDEXED_DB_NAME, INDEXED_DB_VERSION);
      req.onupgradeneeded = () => {
        try {
          req.result.createObjectStore(INDEXED_DB_STORE_NAME);
        } catch (err) {
          reject(
            new Error(
              'Failed to upgrade IDB: ' +
                (err instanceof Error ? err.message : String(err)),
            ),
          );
        }
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => {
        reject(new Error('Failed to open IDB: ' + req.error));
      };
    });
  }

  private async getStore(mode: IDBTransactionMode): Promise<IDBObjectStore> {
    const db = await this.dbPromise;
    return db
      .transaction(INDEXED_DB_STORE_NAME, mode)
      .objectStore(INDEXED_DB_STORE_NAME);
  }

  async get(key: string): Promise<any> {
    const store = await this.getStore(READ_ONLY);
    return new Promise((resolve, reject) => {
      const req = store.get(key);
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }

  async set(key: string, value: any): Promise<void> {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.put(value, key);
  }

  async remove(key: string): Promise<void> {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.delete(key);
  }

  async clear(): Promise<void> {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.clear();
  }
}

/**
 * Web Storage Proxy object, which selects the best backend available
 * depending on the environment.
 */
class StorageProxy implements StorageBackend {
  private backendPromise: Promise<StorageBackend>;
  public impl: StorageImplementation = IMPL_MEMORY;

  constructor() {
    this.backendPromise = (async () => {
      if (!Byond.TRIDENT && testHubStorage()) {
        return new HubStorageBackend();
      }
      // TODO: Remove with 516
      if (testIndexedDb()) {
        try {
          const backend = new IndexedDbBackend();
          await backend.dbPromise;
          return backend;
        } catch {}
      }
      console.warn(
        'No supported storage backend found. Using in-memory storage.',
      );
      return new MemoryBackend();
    })();
  }

  async get(key: string): Promise<any> {
    const backend = await this.backendPromise;
    return backend.get(key);
  }

  async set(key: string, value: any): Promise<void> {
    const backend = await this.backendPromise;
    return backend.set(key, value);
  }

  async remove(key: string): Promise<void> {
    const backend = await this.backendPromise;
    return backend.remove(key);
  }

  async clear(): Promise<void> {
    const backend = await this.backendPromise;
    return backend.clear();
  }
}

export const storage = new StorageProxy();
