/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { inspect } from 'node:util';

import * as WebSocket from 'ws';

import { createLogger, directLog } from '../logging';
import { loadSourceMaps, retrace } from './retrace';

const logger = createLogger('link');

const DEBUG = process.argv.includes('--debug');

export { loadSourceMaps };

export function setupLink(): LinkServer {
  return new LinkServer();
}

class LinkServer {
  wss: WebSocket.Server | null;

  constructor() {
    logger.log('setting up');
    this.wss = null;
    this.setupWebSocketLink();
  }

  // WebSocket-based client link
  setupWebSocketLink(): void {
    const port = 3000;
    this.wss = new WebSocket.WebSocketServer({ port });

    this.wss.on('connection', (ws) => {
      logger.log('client connected');
      ws.on('message', (json) => {
        const msg = deserializeObject(json.toString());
        this.handleLinkMessage(ws, msg);
      });
      ws.on('close', () => {
        logger.log('client disconnected');
      });
    });
    logger.log(`listening on port ${port} (WebSocket)`);
  }

  handleLinkMessage(ws: WebSocket.WebSocket, msg: any): void {
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

  sendMessage(ws: WebSocket.WebSocket, msg: any): void {
    ws.send(JSON.stringify(msg));
  }

  broadcastMessage(msg: any): void {
    if (!this.wss) return;

    const clients = [...this.wss.clients];

    logger.log(`broadcasting ${msg.type} to ${clients.length} clients`);
    for (let client of clients) {
      const json = JSON.stringify(msg);
      client.send(json);
    }
  }
}

function deserializeObject(str: string): any {
  return JSON.parse(str, (_key: string, value: any) => {
    if (typeof value !== 'object' || value === null) return value;

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
  });
}
