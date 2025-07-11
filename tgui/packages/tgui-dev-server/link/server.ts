import { inspect } from 'node:util';

import type { ServerWebSocket } from 'bun';

import { createLogger, directLog } from '../logging';
import { retrace } from './retrace';

let server: Bun.Server;
const logger = createLogger('link');
const DEBUG = process.argv.includes('--debug');

export function setupLink() {
  server = Bun.serve({
    fetch: upgradeServer,
    development: true,
    hostname: '127.0.0.1',
    port: 3000,
    websocket: {
      open(ws) {
        ws.subscribe('link');
        logger.log('client connected');
      },
      close(ws) {
        ws.unsubscribe('link');
        logger.log('client disconnected');
      },
      message: handleLinkMessage,
    },
  });
}

export function broadcastMessage(msg: Record<string, any>): void {
  const subscribers = server.subscriberCount('link');
  if (subscribers === 0) return;

  server?.publish('link', JSON.stringify(msg));
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

function handleLinkMessage(
  _ws: ServerWebSocket<unknown>,
  message: string | Buffer<ArrayBufferLike>,
): void {
  const deserializedMsg = deserializeObject(message);
  const { type, payload } = deserializedMsg;

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
    broadcastMessage(payload);

    return;
  }

  logger.log('unhandled message', JSON.stringify(message));
}

function upgradeServer(req: Request, srv: Bun.Server) {
  const client = crypto.randomUUID();

  const upgraded = srv.upgrade(req, {
    data: {
      id: client,
      createdAt: Date.now(),
    },
  });

  if (upgraded) {
    return new Response('Ok');
  } else {
    return new Response('Upgrade failed', { status: 500 });
  }
}
