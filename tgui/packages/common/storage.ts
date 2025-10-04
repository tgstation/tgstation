/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const IMPL_MEMORY = 0;
export const IMPL_HUB_STORAGE = 1;
export const IMPL_IFRAME_INDEXED_DB = 2;

type StorageImplementation =
  | typeof IMPL_MEMORY
  | typeof IMPL_HUB_STORAGE
  | typeof IMPL_IFRAME_INDEXED_DB;

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

class IFrameIndexedDbBackend implements StorageBackend {
  public impl: StorageImplementation;

  private documentElement: HTMLIFrameElement;
  private iframeWindow: Window;

  constructor() {
    this.impl = IMPL_IFRAME_INDEXED_DB;
  }

  async ready(): Promise<boolean | null> {
    const iframe = document.createElement('iframe');
    iframe.style.display = 'none';
    iframe.src = Byond.storageCdn;

    const completePromise: Promise<boolean> = new Promise((resolve) => {
      iframe.onload = () => resolve(true);
    });

    this.documentElement = document.body.appendChild(iframe);
    if (!this.documentElement.contentWindow) {
      return new Promise((res) => res(false));
    }

    this.iframeWindow = this.documentElement.contentWindow;

    return completePromise;
  }

  async get(key: string): Promise<any> {
    const promise = new Promise((resolve) => {
      window.addEventListener('message', (message) => {
        if (message.data.key && message.data.key === key) {
          resolve(message.data.value);
        }
      });
    });

    this.iframeWindow.postMessage({ type: 'get', key: key }, '*');
    return promise;
  }

  async set(key: string, value: any): Promise<void> {
    this.iframeWindow.postMessage({ type: 'set', key: key, value: value }, '*');
  }

  async remove(key: string): Promise<void> {
    this.iframeWindow.postMessage({ type: 'remove', key: key }, '*');
  }

  async clear(): Promise<void> {
    this.iframeWindow.postMessage({ type: 'clear' }, '*');
  }

  async ping(): Promise<boolean> {
    const promise: Promise<boolean> = new Promise((resolve) => {
      window.addEventListener('message', (message) => {
        if (message.data === true) {
          resolve(true);
        }
      });

      setTimeout(() => resolve(false), 100);
    });

    this.iframeWindow.postMessage({ type: 'ping' }, '*');
    return promise;
  }

  async destroy(): Promise<void> {
    document.body.removeChild(this.documentElement);
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
      if (Byond.storageCdn && !window.hubStorage) {
        const iframe = new IFrameIndexedDbBackend();
        await iframe.ready();

        if ((await iframe.ping()) === true) {
          if (await iframe.get('byondstorage-migrated')) return iframe;

          Byond.winset(null, 'browser-options', '+byondstorage');

          await new Promise<void>((resolve) => {
            document.addEventListener('byondstorageupdated', async () => {
              setTimeout(() => {
                const hub = new HubStorageBackend();

                for (const setting of ['panel-settings', 'chat-state', 'chat-messages']) {
                  hub
                    .get(setting)
                    .then((settings) => iframe.set(setting, settings));
                }

                iframe.set('byondstorage-migrated', true);
                Byond.winset(null, 'browser-options', '-byondstorage');

                resolve();
              }, 1);
            });
          });

          return iframe;
        }

        iframe.destroy();

        if (!testHubStorage()) {
          Byond.winset(null, 'browser-options', '+byondstorage');

          return new Promise((resolve) => {
            const listener = () => {
              document.removeEventListener('byondstorageupdated', listener);
              resolve(new HubStorageBackend());
            };

            document.addEventListener('byondstorageupdated', listener);
          });
        }
        return new HubStorageBackend();
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
