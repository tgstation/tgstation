let socket;

export const sendLogEntry = (ns, ...args) => {
  if (process.env.NODE_ENV !== 'production') {
    try {
      if (!socket) {
        socket = new WebSocket('ws://localhost:3001');
      }
      socket.send(JSON.stringify({
        type: 'log',
        payload: { ns, args },
      }));
    }
    catch (err) {}
  }
};
