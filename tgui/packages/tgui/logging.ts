/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { sendLogEntry } from 'tgui-dev-server/link/client.cjs';

const LEVEL_DEBUG = 0;
const LEVEL_LOG = 1;
const LEVEL_INFO = 2;
const LEVEL_WARN = 3;
const LEVEL_ERROR = 4;

interface Logger {
  debug: (...args: any[]) => void;
  log: (...args: any[]) => void;
  info: (...args: any[]) => void;
  warn: (...args: any[]) => void;
  error: (...args: any[]) => void;
}

const log = (level: number, namespace = 'Generic', ...args: any[]): void => {
  // Send logs to a remote log collector
  if (process.env.NODE_ENV !== 'production') {
    sendLogEntry(level, namespace, ...args);
  }
  // Send important logs to the backend
  if (level >= LEVEL_INFO) {
    const logEntry =
      [namespace, ...args]
        .map((value) => {
          if (typeof value === 'string') {
            return value;
          }
          if (value instanceof Error) {
            return value.stack || String(value);
          }
          return JSON.stringify(value);
        })
        .filter((value) => value)
        .join(' ') +
      '\nUser Agent: ' +
      navigator.userAgent;
    Byond.sendMessage({
      type: 'log',
      ns: namespace,
      message: logEntry,
    });
  }
};

export const createLogger = (namespace?: string): Logger => {
  return {
    debug: (...args) => log(LEVEL_DEBUG, namespace, ...args),
    log: (...args) => log(LEVEL_LOG, namespace, ...args),
    info: (...args) => log(LEVEL_INFO, namespace, ...args),
    warn: (...args) => log(LEVEL_WARN, namespace, ...args),
    error: (...args) => log(LEVEL_ERROR, namespace, ...args),
  };
};

/**
 * A generic instance of the logger.
 *
 * Does not have a namespace associated with it.
 */
export const logger: Logger = createLogger();
