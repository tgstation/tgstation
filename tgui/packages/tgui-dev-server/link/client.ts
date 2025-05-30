/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type Messenger = (msg: any) => void;

let socket: WebSocket;
const queue: string[] = [];
const subscribers: Messenger[] = [];

function ensureConnection(): void {
  if (process.env.NODE_ENV === 'production') return;

  if (socket && socket.readyState !== WebSocket.CLOSED) return;

  sendLogEntry(0, null, 'ensuring connection');
  sendLogEntry(0, null, 'using WebSocket', window.WebSocket);

  if (!window.WebSocket) return;

  const DEV_SERVER_IP = process.env.DEV_SERVER_IP || '127.0.0.1';

  socket = new WebSocket(`ws://${DEV_SERVER_IP}:3000`);

  socket.onopen = () => {
    // Empty the message queue
    while (queue.length !== 0) {
      const msg = queue.shift();
      if (msg) {
        socket.send(msg);
      }
    }
  };

  socket.onmessage = (event) => {
    const msg = JSON.parse(event.data);
    for (let subscriber of subscribers) {
      subscriber(msg);
    }
  };

  window.addEventListener('unload', () => socket?.close());
}

export function subscribe(fn: Messenger): void {
  subscribers.push(fn);
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

export function sendMessage(msg: Record<string, any>): void {
  if (process.env.NODE_ENV === 'production' || !socket) return;

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

export function sendLogEntry(
  level: number,
  ns: string | null = 'client',
  ...args: any[]
): void {
  if (process.env.NODE_ENV === 'production') return;

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

export function setupHotReloading(): void {
  if (
    process.env.NODE_ENV === 'production' ||
    !process.env.WEBPACK_HMR_ENABLED ||
    !window.WebSocket
  ) {
    return;
  }

  const hot = import.meta.webpackHot;
  if (!hot) return;

  ensureConnection();
  sendLogEntry(0, null, 'setting up hot reloading');
  subscribe(({ type }) => {
    sendLogEntry(0, null, 'received', type);
    if (type !== 'hotUpdate') return;

    const status = hot.status();
    if (status !== 'idle') {
      sendLogEntry(0, null, 'hot reload status:', status);
      return;
    }

    hot
      .apply({
        ignoreUnaccepted: true,
        ignoreDeclined: true,
        ignoreErrored: true,
      })
      .then((modules) => {
        sendLogEntry(0, null, 'outdated modules', modules);
      })
      .catch((err) => {
        sendLogEntry(0, null, 'reload error', err);
      });
  });
}
