/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

let socket;
const queue = [];
const subscribers = [];

function ensureConnection() {
  if (process.env.NODE_ENV === 'production') return;

  if (socket && socket.readyState !== WebSocket.CLOSED) return;

  if (!window.WebSocket) return;

  const DEV_SERVER_IP = process.env.DEV_SERVER_IP || '127.0.0.1';

  socket = new WebSocket(`ws://${DEV_SERVER_IP}:3000`);

  socket.onopen = () => {
    // Empty the message queue
    while (queue.length !== 0) {
      const msg = queue.shift();
      socket.send(msg);
    }
  };

  socket.onmessage = (event) => {
    const msg = JSON.parse(event.data);
    for (let subscriber of subscribers) {
      subscriber(msg);
    }
  };

  window.onunload = () => socket?.close();
}

export function subscribe(fn) {
  subscribers.push(fn);
}

function primitiveReviver(value) {
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

/**
 * A json serializer which handles circular references and other junk.
 */
function serializeObject(obj) {
  let refs = [];

  function objectReviver(key, value) {
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
  refs = null;
  return json;
}

export function sendMessage(msg) {
  if (process.env.NODE_ENV === 'production') return;

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

export function sendLogEntry(level, ns, ...args) {
  if (process.env.NODE_ENV !== 'production') {
    try {
      sendMessage({
        type: 'log',
        payload: {
          level,
          ns: ns || 'client',
          args,
        },
      });
    } catch (err) {}
  }
}

export function setupHotReloading() {
  if (
    process.env.NODE_ENV === 'production' ||
    !process.env.WEBPACK_HMR_ENABLED ||
    !window.WebSocket
  ) {
    return;
  }
  if (!import.meta.webpackHot) return;

  ensureConnection();
  sendLogEntry(0, null, 'setting up hot reloading');
  subscribe(({ type }) => {
    sendLogEntry(0, null, 'received', type);
    if (type !== 'hotUpdate') return;

    const status = import.meta.webpackHot.status();
    if (status !== 'idle') {
      sendLogEntry(0, null, 'hot reload status:', status);
      return;
    }

    import.meta.webpackHot
      .check({
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
