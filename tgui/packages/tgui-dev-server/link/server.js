/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { inspect } from 'node:util';

import * as WebSocket from 'ws';

import { createLogger, directLog } from '../logging.js';
import { loadSourceMaps, retrace } from './retrace.js';

const logger = createLogger('link');

const DEBUG = process.argv.includes('--debug');

export { loadSourceMaps };

export function setupLink() {
  return new LinkServer();
}

class LinkServer {
  constructor() {
    logger.log('setting up');
    /** @type {WebSocket.Server | null} */
    this.wss = null;
    this.setupWebSocketLink();
  }

  // WebSocket-based client link
  setupWebSocketLink() {
    const port = 3000;
    this.wss = new WebSocket.WebSocketServer({ port });

    this.wss.on('connection', (ws) => {
      logger.log('client connected');
      ws.on('message', (json) => {
        const msg = deserializeObject(json);
        this.handleLinkMessage(ws, msg);
      });
      ws.on('close', () => {
        logger.log('client disconnected');
      });
    });
    logger.log(`listening on port ${port} (WebSocket)`);
  }

  /**
   * @param {WebSocket.Client} ws
   * @param {WebSocket.MessageEvent} msg
   */
  handleLinkMessage(ws, msg) {
    const { type, payload } = msg;
    if (type === 'log') {
      const { level, ns, args } = payload;
      // Skip debug messages
      if (level <= 0 && !DEBUG) {
        return;
      }

      directLog(
        ns,
        ...args.map((arg) => {
          if (typeof arg === 'object') {
            return inspect(arg, {
              depth: Infinity,
              colors: true,
              compact: 8,
            });
          }
          return arg;
        }),
      );
      return;
    }
    if (type === 'relay') {
      if (!this.wss) {
        return;
      }
      for (let client of this.wss.clients) {
        if (client === ws) {
          continue;
        }
        this.sendMessage(client, msg);
      }
      return;
    }
    logger.log('unhandled message', msg);
  }

  sendMessage(ws, msg) {
    ws.send(JSON.stringify(msg));
  }

  broadcastMessage(msg) {
    if (!this.wss) {
      return;
    }
    const clients = [...this.wss.clients];
    if (clients.length === 0) {
      return;
    }
    logger.log(`broadcasting ${msg.type} to ${clients.length} clients`);
    for (let client of clients) {
      const json = JSON.stringify(msg);
      client.send(json);
    }
  }
}

function deserializeObject(str) {
  return JSON.parse(str, (key, value) => {
    if (typeof value === 'object' && value !== null) {
      if (value.__undefined__) {
        // NOTE: You should not rely on deserialized object's undefined,
        // this is purely for inspection purposes.
        return {
          [inspect.custom]: () => undefined,
        };
      }
      if (value.__number__) {
        return parseFloat(value.__number__);
      }
      if (value.__error__) {
        if (!value.stack) {
          return value.string;
        }
        return retrace(value.stack);
      }
      return value;
    }
    return value;
  });
}
