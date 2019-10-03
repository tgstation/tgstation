import { sendLogEntry } from 'tgui-dev-server/link/client';

const log = (ns, ...args) => {
  // Send logs to a remote log collector
  if (process.env.NODE_ENV !== 'production') {
    sendLogEntry(ns, ...args);
  }
  // Send logs to a globally defined debug print
  if (window.debugPrint) {
    debugPrint([ns, ...args]);
  }
};

export const createLogger = ns => {
  return {
    log: (...args) => log(ns, ...args),
    info: (...args) => log(ns, ...args),
    error: (...args) => log(ns, ...args),
    warn: (...args) => log(ns, ...args),
    debug: (...args) => log(ns, ...args),
  };
};
