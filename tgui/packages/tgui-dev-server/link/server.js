import { createLogger, directLog } from 'common/logging.js';
import http from 'http';
import { inspect } from 'util';
import WebSocket from 'ws';
import { retrace, loadSourceMaps } from './retrace.js';

const logger = createLogger('link');

const DEBUG = process.argv.includes('--debug');

export { loadSourceMaps };

export const setupLink = () => {
  logger.log('setting up');
  const wss = setupWebSocketLink();
  setupHttpLink();
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

const deserializeObject = str => {
  return JSON.parse(str, (key, value) => {
    if (typeof value === 'object' && value !== null) {
      if (value.__error__) {
        if (!value.stack) {
          return value.string;
        }
        return retrace(value.stack);
      }
      if (value.__number__) {
        return parseFloat(value.__number__);
      }
      if (value.__undefined__) {
        // NOTE: You should not rely on deserialized object's undefined,
        // this is purely for inspection purposes.
        return {
          [inspect.custom]: () => undefined,
        };
      }
      return value;
    }
    return value;
  });
};

const handleLinkMessage = msg => {
  const { type, payload } = msg;

  if (type === 'log') {
    const { level, ns, args } = payload;
    // Skip debug messages
    if (level <= 0 && !DEBUG) {
      return;
    }
    directLog(ns, ...args.map(arg => {
      if (typeof arg === 'object') {
        return inspect(arg, {
          depth: Infinity,
          colors: true,
          compact: 8,
        });
      }
      return arg;
    }));
    return;
  }

  logger.log('unhandled message', msg);
};

// WebSocket-based client link
const setupWebSocketLink = () => {
  const port = 3000;
  const wss = new WebSocket.Server({ port });

  wss.on('connection', ws => {
    logger.log('client connected');

    ws.on('message', json => {
      const msg = deserializeObject(json);
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
const setupHttpLink = () => {
  const port = 3001;

  const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
      let body = '';
      req.on('data', chunk => {
        body += chunk.toString();
      });
      req.on('end', () => {
        const msg = deserializeObject(body);
        handleLinkMessage(msg);
        res.end();
      });
      return;
    }
    res.write('Hello');
    res.end();
  });

  server.listen(port);
  logger.log(`listening on port ${port} (HTTP)`);
};
