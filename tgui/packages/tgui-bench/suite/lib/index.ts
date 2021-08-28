import { createRenderer } from 'tgui/renderer';

export { default as Benchmark } from './benchmark';

export const render = createRenderer((vNode: unknown) => vNode);
