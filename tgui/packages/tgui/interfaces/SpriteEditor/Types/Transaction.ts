import { Dir, StringLayer } from './types';

export interface LayerTransaction {
  dir: Dir;
  layer: number;
  getPreviewLayer(baseLayer: StringLayer): StringLayer;
  commit(): void;
}
