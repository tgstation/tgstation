import type { Dir, StringLayer } from './types';

export type LayerTransaction = {
  dir: Dir;
  layer: number;
  getPreviewLayer(baseLayer: StringLayer): StringLayer;
  commit(): void;
};
