import { sendLogEntry } from 'tgui-dev-server/link/client';
import { act } from './byond';

let _ref = null;

export const setLoggerRef = ref => {
  _ref = ref;
};

const LEVEL_ERROR = 0;
const LEVEL_WARN = 1;
const LEVEL_INFO = 2;
const LEVEL_LOG = 3;
const LEVEL_DEBUG = 4;

const log = (level, ns, ...args) => {
  // Send logs to a remote log collector
  if (process.env.NODE_ENV !== 'production') {
    sendLogEntry(ns, ...args);
  }
  // Send logs to a globally defined debug print
  if (window.debugPrint) {
    debugPrint([ns, ...args]);
  }
  // Send important logs to the backend
  if (level >= LEVEL_WARN) {
    const logEntry = [ns, ...args]
      .map(value => {
        if (typeof value === 'string') {
          return value;
        }
        return JSON.stringify(value);
      })
      .filter(value => value)
      .join(' ')
      + '\nUser Agent: ' + navigator.userAgent;
    act(_ref, 'tgui:log', {
      error: level === LEVEL_ERROR,
      log: logEntry,
    });
  }
};

export const createLogger = ns => {
  return {
    log: (...args) => log(LEVEL_ERROR, ns, ...args),
    debug: (...args) => log(LEVEL_DEBUG, ns, ...args),
    info: (...args) => log(LEVEL_INFO, ns, ...args),
    warn: (...args) => log(LEVEL_LOG, ns, ...args),
    error: (...args) => log(LEVEL_WARN, ns, ...args),
  };
};
