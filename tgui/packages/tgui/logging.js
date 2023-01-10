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

const log = (level, ns, ...args) => {
  // Send logs to a remote log collector
  if (process.env.NODE_ENV !== 'production') {
    sendLogEntry(level, ns, ...args);
  }
  // Send important logs to the backend
  if (level >= LEVEL_INFO) {
    // prettier-ignore
    const logEntry = [ns, ...args]
      .map(value => {
        if (typeof value === 'string') {
          return value;
        }
        if (value instanceof Error) {
          return value.stack || String(value);
        }
        return JSON.stringify(value);
      })
      .filter(value => value)
      .join(' ')
      + '\nUser Agent: ' + navigator.userAgent;
    Byond.sendMessage({
      type: 'log',
      ns,
      message: logEntry,
    });
  }
};

export const createLogger = (ns) => {
  return {
    debug: (...args) => log(LEVEL_DEBUG, ns, ...args),
    log: (...args) => log(LEVEL_LOG, ns, ...args),
    info: (...args) => log(LEVEL_INFO, ns, ...args),
    warn: (...args) => log(LEVEL_WARN, ns, ...args),
    error: (...args) => log(LEVEL_ERROR, ns, ...args),
  };
};

/**
 * A generic instance of the logger.
 *
 * Does not have a namespace associated with it.
 */
export const logger = createLogger();
