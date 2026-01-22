import { mock } from 'bun:test';
import './byond';
import './layouts';
import './tgui-core';

mock.module('../backend', () => ({
  useBackend: mock(() => ({
    act: mock(() => {}),
    data: {},
  })),
}));

mock.module('../logging', () => ({
  log: mock(() => {}),
  error: mock(() => {}),
  warn: mock(() => {}),
  info: mock(() => {}),
}));
