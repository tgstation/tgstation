import { Dir, Layer } from './types';
import { Workspace } from './Workspace';

export interface Transaction {
  name: string;
  commit: (workspace: Workspace) => void;
  undo: (workspace: Workspace) => void;
}

export interface LayerTransaction extends Transaction {
  dir: Dir;
  layer: number;
  applyPreview(layer: Layer);
}
