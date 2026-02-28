/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const IMPL_HUB_STORAGE = 1;
export const IMPL_IFRAME_INDEXED_DB = 2;

type StorageImplementation =
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
      fetch(Byond.storageCdn, { method: "HEAD" }).then((response) => {
        if (response.status !== 200) {
          resolve(false);
        }

      }).catch(() => {
        resolve(false);
      })

      window.addEventListener('message', (message) => {
        if (message.data === "ready") {
          resolve(true);
        }
      })
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
  public impl: StorageImplementation = IMPL_IFRAME_INDEXED_DB;

  constructor() {
    this.backendPromise = (async () => {

      // If we have not enabled byondstorage yet, we need to check
      // if we can use the IFrame, or if we need to enable byondstorage
      if (!testHubStorage()) {

        // If we have an IFrame URL we can use, and we haven't already enabled
        // byondstorage, we should use the IFrame backend
        if (Byond.storageCdn) {
          const iframe = new IFrameIndexedDbBackend();

          if ((await iframe.ready()) === true) {
            if (await iframe.get('byondstorage-migrated')) return iframe;

            Byond.winset(null, 'browser-options', '+byondstorage');

            await new Promise<void>((resolve) => {
              document.addEventListener('byondstorageupdated', async () => {
                setTimeout(() => {
                  const hub = new HubStorageBackend();

                  // Migrate these existing settings from byondstorage to the IFrame
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
        };

        // IFrame hasn't worked out for us, we'll need to enable byondstorage
        Byond.winset(null, 'browser-options', '+byondstorage');

        return new Promise((resolve) => {
          const listener = () => {
            document.removeEventListener('byondstorageupdated', listener);

            // This event is emitted *before* byondstorage is actually created
            // so we have to wait a little bit before we can use it
            setTimeout(() => resolve(new HubStorageBackend()), 1);
          };

          document.addEventListener('byondstorageupdated', listener);
        });
      }

      // byondstorage is already enabled, we can use it straight away
      return new HubStorageBackend();
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
