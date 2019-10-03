import { createLogger, directLog } from 'common/logging.js';
import http from 'http';
import WebSocket from 'ws';

const logger = createLogger('link');

export const setupLink = () => {
  logger.log('setting up');
  const wss = setupWebSocketLink();
  setupSimpleLink();
  return {
    wss,
  };
};

export const broadcastMessage = (link, msg) => {
  const { wss } = link;
  const clients = [...wss.clients];
  logger.log(`broadcasting ${msg.type} to ${clients.length} clients`);
  for (let client of clients) {
    const json = JSON.stringify(msg);
    client.send(json);
  }
};

const handleLinkMessage = msg => {
  const { type, payload } = msg;

  if (type === 'log') {
    const { ns, args } = payload;
    directLog(ns, ...args);
    return;
  }

  logger.log('unhandled message', msg);
};

// WebSocket-based client link
const setupWebSocketLink = () => {
  const logger = createLogger('link');
  const port = 3000;
  const wss = new WebSocket.Server({ port });

  wss.on('connection', ws => {
    logger.log('client connected');

    ws.on('message', json => {
      const msg = JSON.parse(json);
      handleLinkMessage(msg);
    });

    ws.on('close', () => {
      logger.log('client disconnected');
    });
  });

  logger.log(`listening on port ${port} (WebSocket)`);
  return wss;
};

// One way HTTP-based client link for IE8
const setupSimpleLink = () => {
  const logger = createLogger('link');
  const port = 3001;

  const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
      let body = '';
      req.on('data', chunk => {
        body += chunk.toString();
      });
      req.on('end', () => {
        const msg = JSON.parse(body);
        handleLinkMessage(msg);
        res.end();
      });
      return;
    }
    res.end();
  });

  server.listen(port);
  logger.log(`listening on port ${port} (HTTP)`);
};
