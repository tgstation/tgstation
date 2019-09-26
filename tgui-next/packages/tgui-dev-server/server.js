import ws from 'ws';
import { createLogger } from 'logging';

const logger = createLogger('server');

const socket = new ws.Server({
  port: 3001,
});

let clientCounter = 0;

socket.on('connection', ws => {
  const clientId = ++clientCounter;
  const logger = createLogger(`client ${clientId}`);

  logger.log('connected');

  ws.on('message', msg => {
    const { type, payload } = JSON.parse(msg);
    if (type === 'log') {
      const { ns, args } = payload;
      logger.log(...args);
      return;
    }
  });

  ws.on('close', () => {
    logger.log('disconnected');
  });
});

logger.log('listening');
