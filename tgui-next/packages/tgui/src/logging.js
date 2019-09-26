import { sendLogEntry } from 'tgui-dev-server/client';

const log = (ns, ...args) => {
  console.log(...args);
  if (process.env.NODE_ENV !== 'production') {
    sendLogEntry('', ...args);
  }
};

// TODO: Add namespace support.
export const createLogger = ns => ({
  log: (...args) => log(ns, ...args),
  info: (...args) => log(ns, ...args),
  error: (...args) => log(ns, ...args),
  warn: (...args) => log(ns, ...args),
  debug: (...args) => log(ns, ...args),
});
