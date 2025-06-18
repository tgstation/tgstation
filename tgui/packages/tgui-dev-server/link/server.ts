import { inspect } from 'node:util';

import { createLogger, directLog } from '../logging';
import { retrace } from './retrace';

const logger = createLogger('link');

export function setupLink() {
  return new LinkServer();
}

class LinkServer {
  server: Bun.Server;

  constructor() {
    this.server = Bun.serve({
      fetch() {
        return new Response('ok');
      },
      port: 3000,
      websocket: {
        open(ws) {
          ws.subscribe('link');
          logger.log('client connected');
        },
        message(_ws, message) {
          const msg = deserializeObject(message);
          this.handleLinkMessage(msg);
        },
        close(ws) {
          ws.unsubscribe('link');
          logger.log('client disconnected');
        },
      },
    });
  }

  handleLinkMessage(msg: Record<string, any>): void {
    const { type, payload } = msg;

    if (type === 'log') {
      const { level, ns, args } = payload;
      // Skip debug messages
      if (level <= 0 && !DEBUG) return;

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
      this.broadcastMessage(payload);

      return;
    }
    logger.log('unhandled message', msg);
  }

  broadcastMessage(msg: Record<string, any>): void {
    logger.log(
      `broadcasting message to ${this.server.subscriberCount('link')} clients`,
    );
    this.server?.publish('link', JSON.stringify(msg));
  }
}

function deserializeObject(str: any): any {
  return JSON.parse(str, (_key: string, value: any) => {
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
