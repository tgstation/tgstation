let socket;
let socketIsOpen = false;

const queue = [];

export const sendLogEntry = (ns, ...args) => {
  if (process.env.NODE_ENV !== 'production') {
    try {
      if (!socket) {
        socket = new WebSocket('ws://localhost:3001');
      }
      socket.onopen = () => {
        socketIsOpen = true;
        for (let msg of queue) {
          socket.send(msg);
        }
      };
      const msg = JSON.stringify({
        type: 'log',
        payload: { ns, args },
      });
      if (socketIsOpen) {
        socket.send(msg);
      }
      else {
        queue.push(msg);
      }
    }
    catch (err) {}
  }
};
