type Messenger = (msg: any) => void;

let socket: WebSocket | undefined;
const queue: string[] = [];
const subscribers: Messenger[] = [];

function ensureConnection() {
  if (socket) return;
  console.log('Creating a connection');

  socket = new WebSocket('ws://127.0.0.1:3000');

  socket.onopen = () => {
    // Empty the message queue
    while (queue.length !== 0) {
      const msg = queue.shift();
      if (msg) {
        socket?.send(msg);
      }
    }
  };

  socket.onmessage = (event) => {
    const msg = JSON.parse(event.data);
    for (const subscriber of subscribers) {
      subscriber(msg);
    }
  };

  socket.onerror = (err) => {
    console.log('WebSocket error:', err);
  };

  window.addEventListener('unload', () => socket?.close());
}

function primitiveReviver(value: unknown): any {
  if (typeof value === 'number' && !Number.isFinite(value)) {
    return {
      __number__: String(value),
    };
  }
  if (typeof value === 'undefined') {
    return {
      __undefined__: true,
    };
  }
  return value;
}

export function sendLogEntry(
  level: number,
  ns: string | null = 'client',
  ...args: any[]
): void {
  if (process.env.NODE_ENV === 'development') {
    try {
      sendMessage({
        type: 'log',
        payload: {
          level,
          ns,
          args,
        },
      });
    } catch (err) {}
  }
}

export function sendMessage(msg: Record<string, any>): void {
  if (process.env.NODE_ENV === 'development' && socket) {
    const json = serializeObject(msg);
    // Send message using WebSocket
    if (!window.WebSocket) return;

    ensureConnection();
    if (socket.readyState === WebSocket.OPEN) {
      socket.send(json);
    } else {
      // Keep only 100 latest messages in the queue
      if (queue.length > 100) {
        queue.shift();
      }
      queue.push(json);
    }
  }
}

/** A json serializer which handles circular references and other junk. */
function serializeObject(obj: Record<string, any>): string {
  let refs: string[] = [];

  function objectReviver(key: string, value: any) {
    if (typeof value !== 'object') {
      return primitiveReviver(value);
    }

    if (value === null) {
      return value;
    }
    // Circular reference
    if (refs.includes(value)) {
      return '[circular ref]';
    }
    refs.push(value);
    // Error object
    const isError =
      value instanceof Error ||
      (value.code && value.message && value.message.includes('Error'));
    if (isError) {
      return {
        __error__: true,
        string: String(value),
        stack: value.stack,
      };
    }
    // Array
    if (Array.isArray(value)) {
      return value.map(primitiveReviver);
    }
    return value;
  }

  const json = JSON.stringify(obj, objectReviver);
  refs = [];
  return json;
}

export function setupHotReloading(): void {
  if (process.env.NODE_ENV === 'development' && window.WebSocket) {
    console.log('Setting up hot reloading...');
    if (socket) {
      socket.close();
      socket = undefined;
      subscribers.length = 0;
    }
    ensureConnection();
    subscribe(({ type }) => {
      if (type !== 'hotUpdate') return;

      const status = import.meta.webpackHot?.status();
      if (status === 'ready') {
        import.meta.webpackHot
          ?.apply({
            ignoreUnaccepted: true,
            ignoreDeclined: true,
            ignoreErrored: true,
          })
          .then((modules) => {
            console.log('outdated modules:', modules);
          })
          .catch((err) => {
            console.log(import.meta.webpackHot?.status());
            console.error('Hot reload error:', err);
          });
      } else if (status === 'idle') {
        import.meta.webpackHot
          ?.check(true)
          .then((updatedModules) => {
            console.log('Updated modules:', updatedModules);
          })
          .catch((err) => {
            console.error('Hot reload error:', err);
          });
      }
    });
  }
}

export function subscribe(fn: Messenger): void {
  subscribers.push(fn);
}
