import { mock } from 'bun:test';

const ByondMock = {
  windowId: 'test-window',
  IS_BYOND: true,
  BLINK: true,
  strictMode: true,
  storageCdn: '',

  call: mock(() => {}),
  callAsync: mock(async () => ({})),
  topic: mock(() => {}),
  command: mock(() => {}),

  winget: mock(async () => ({})),
  winset: mock(() => {}),

  parseJson: (text: string) => JSON.parse(text),

  sendMessage: mock(() => {}),
  subscribe: mock(() => {}),
  subscribeTo: mock(() => {}),

  loadCss: mock(() => {}),
  loadJs: mock(() => {}),

  iconRefMap: {},
  saveBlob: mock(() => {}),
};

mock.module('globalThis', () => ({
  Byond: ByondMock,
}));
