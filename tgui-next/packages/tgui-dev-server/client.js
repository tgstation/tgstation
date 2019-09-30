let socket;
const queue = [];
const subscribers = [];

const ensureConnection = () => {
  if (process.env.NODE_ENV !== 'production') {
    if (!socket || socket.readyState === WebSocket.CLOSED) {
      socket = new WebSocket('ws://localhost:3000');
      socket.onopen = () => {
        // Empty the message queue
        while (queue.length !== 0) {
          const msg = queue.pop();
          socket.send(msg);
        }
      };
      socket.onmessage = event => {
        const msg = JSON.parse(event.data);
        for (let subscriber of subscribers) {
          subscriber(msg);
        }
      };
    }
  }
};

if (process.env.NODE_ENV !== 'production') {
  window.onunload = () => socket && socket.close();
}

const subscribe = fn => subscribers.push(fn);

const sendRawMessage = msg => {
  if (process.env.NODE_ENV !== 'production') {
    ensureConnection();
    const json = JSON.stringify(msg);
    if (socket.readyState === WebSocket.OPEN) {
      socket.send(json);
    }
    else {
      // Keep only 10 latest messages in the queue
      if (queue.length > 10) {
        queue.shift();
      }
      queue.push(json);
    }
  }
};

export const sendLogEntry = (ns, ...args) => {
  if (process.env.NODE_ENV !== 'production') {
    try {
      sendRawMessage({
        type: 'log',
        payload: {
          ns: ns || 'client',
          args,
        },
      });
    }
    catch (err) {}
  }
};

export const setupHotReloading = () => {
  if (process.env.NODE_ENV !== 'production') {
    if (module.hot) {
      ensureConnection();
      sendLogEntry(null, 'setting up hot reloading');
      subscribe(async msg => {
        const { type, payload } = msg;
        sendLogEntry(null, 'received', type);
        if (type === 'hotUpdate') {
          try {
            const status = module.hot.status();
            if (status !== 'idle') {
              sendLogEntry(null, 'hot reload status:', status);
            }
            await module.hot.check({
              ignoreUnaccepted: true,
              ignoreDeclined: true,
              ignoreErrored: true,
            });
          }
          catch (err) {
            sendLogEntry(null, 'reload error', err);
          }
        }
      });
    }
  }
};
