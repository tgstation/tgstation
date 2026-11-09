import { mock } from 'bun:test';

import './byond';
import './layouts';

const logger = {
  debug: () => {},
  error: () => {},
  info: () => {},
  log: () => {},
  warn: () => {},
};

mock.module('../logging', () => ({
  createLogger: () => logger,
  logger,
}));

mock.module('../events/act', () => ({
  sendAct: () => ({}),
}));
