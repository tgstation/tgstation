import { normal } from 'color-blend';
import { useSyncExternalStore } from 'react';

import { hsv2rgb, isRgb } from '../colorSpaces';
import { bytes2Base64UrlSafe, matrix } from '../helpers';
import { Icon } from './Icon';
import { LayerTransaction, Transaction } from './Transaction';
import { EditorColor, PixelDelta } from './types';
import { Dir, Layer, RGBA, SerializedIcon, SubscribeFn } from './types';

export type LayerMetadata = {
  visible: boolean;
  name: string;
};

export class Workspace {
  icon: Icon;
  selectedDir = Dir.SOUTH;
  selectedLayer = 0;
  metadata: LayerMetadata[] = [];

  pendingTransaction: LayerTransaction | null = null;
  undoStack: Transaction[] = [];
  redoStack: Transaction[] = [];
  onTransaction: Set<() => void> = new Set();
  notifyTransaction() {
    this.onTransaction.forEach((cb) => cb());
  }

  onMarkMainCanvasDataDirty: Set<() => void> = new Set();
  cachedMainCanvasData: Layer = [];
  markMainCanvasDataDirty() {
    this.cachedMainCanvasData = this.generateMainCanvasData();
    this.onMarkMainCanvasDataDirty.forEach((cb) => cb());
  }
  getCachedMainCanvasData: () => Layer = (() => {
    return this.cachedMainCanvasData;
  }).bind(this);

  onMetadataModified: Set<() => void> = new Set();
  cachedMetadata: LayerMetadata[] = [];
  markMetadataChanged() {
    this.cachedMetadata = [...this.metadata];
    this.onMetadataModified.forEach((cb) => cb());
  }
  getCachedMetadata: () => LayerMetadata[] = (() => {
    return this.cachedMetadata;
  }).bind(this);

  onDeltasBroadcast: Set<(deltas: PixelDelta[]) => void> = new Set();
  broadcastDeltas(deltas: PixelDelta[]) {
    this.onDeltasBroadcast.forEach((cb) => cb(deltas));
  }

  getPrimaryColor: (() => EditorColor) | null = null;

  constructor(icon: Icon) {
    this.icon = icon;
    for (let i = 0; i < icon.layerCount; i++) {
      this.metadata.push({
        visible: true,
        name: i === 0 ? 'Background' : `Layer ${i}`,
      });
    }
    this.markMainCanvasDataDirty();
    this.markMetadataChanged();
  }

  commitTransaction(transaction?: Transaction) {
    if (!transaction && !this.pendingTransaction) return;
    this.redoStack = [];
    transaction ??= this.pendingTransaction!;
    this.pendingTransaction = null;
    transaction.commit(this);
    this.undoStack = [...this.undoStack, transaction];
    this.notifyTransaction();
  }

  discardPendingTransaction() {
    if (!this.pendingTransaction) return;
    this.pendingTransaction = null;
  }

  undo() {
    const { length } = this.undoStack;
    const transaction = this.undoStack[length - 1];
    if (!transaction) return;
    transaction.undo(this);
    this.undoStack = this.undoStack.slice(0, -1);
    this.redoStack = [...this.redoStack, transaction];
    this.notifyTransaction();
  }

  redo() {
    const { length } = this.redoStack;
    const transaction = this.redoStack[length - 1];
    if (!transaction) return;
    transaction.commit(this);
    this.redoStack = this.redoStack.slice(0, -1);
    this.undoStack = [...this.undoStack, transaction];
    this.notifyTransaction();
  }

  generateMainCanvasData() {
    return this.generateFlatLayerStack();
  }

  generateFlatLayerStack(
    dir: Dir = this.selectedDir,
    respectVisibility: boolean = true,
    applyPendingTransaction: boolean = true,
  ): RGBA[][] {
    let ret: Required<RGBA>[][] = matrix<EditorColor>(
      () => ({ r: 0, g: 0, b: 0, a: 0 }),
      this.icon.width,
      this.icon.height,
    )();
    this.icon.getStack(dir)!.forEach((layer, layerIndex) => {
      if (respectVisibility && !this.metadata[layerIndex].visible) return;
      layer.forEach((row, y) => {
        row.forEach((pixel, x) => {
          const { a = 1 } = pixel;
          const { r, g, b } = isRgb(pixel) ? pixel : hsv2rgb(pixel);
          ret[y][x] = normal(ret[y][x], { r, g, b, a });
        });
      });
      if (
        applyPendingTransaction &&
        this.pendingTransaction !== null &&
        this.pendingTransaction.layer === layerIndex
      ) {
        this.pendingTransaction.applyPreview(ret);
      }
    });
    return ret;
  }

  async serializeIcon(): Promise<SerializedIcon> {
    const { icon } = this;
    const {
      width,
      height,
      inner: { dirs },
    } = icon;
    return {
      width,
      height,
      states: [
        {
          name: '',
          dirs,
          samples: await bytes2Base64UrlSafe(
            new Uint8Array(
              icon
                .stacks()
                .map(([dir]) => this.generateFlatLayerStack(dir, false, false))
                .flat(2)
                .flatMap((color) => {
                  const { r, g, b, a = 1 } = color;
                  return [r, g, b, Math.round(a * 255)];
                }),
            ),
          ),
        },
      ],
    };
  }

  subscribeToMainCanvasData: SubscribeFn = ((onStoreChanged: () => void) => {
    this.onMarkMainCanvasDataDirty.add(onStoreChanged);
    return () => this.onMarkMainCanvasDataDirty.delete(onStoreChanged);
  }).bind(this);

  useMainCanvasData(): Layer {
    return useSyncExternalStore(
      this.subscribeToMainCanvasData,
      this.getCachedMainCanvasData,
    );
  }

  subscribeToUndoStack: SubscribeFn = ((onStoreChanged: () => void) => {
    this.onTransaction.add(onStoreChanged);
    return () => this.onTransaction.delete(onStoreChanged);
  }).bind(this);

  useUndoStack(): Transaction[] {
    return useSyncExternalStore(
      this.subscribeToUndoStack,
      () => this.undoStack,
    );
  }

  subscribeToRedoStack: SubscribeFn = ((onStoreChanged: () => void) => {
    this.onTransaction.add(onStoreChanged);
    return () => this.onTransaction.delete(onStoreChanged);
  }).bind(this);

  useRedoStack(): Transaction[] {
    return useSyncExternalStore(
      this.subscribeToRedoStack,
      () => this.redoStack,
    );
  }

  subscribeToMetadata: SubscribeFn = ((onStoreChanged: () => void) => {
    this.onMetadataModified.add(onStoreChanged);
    return () => this.onMetadataModified.delete(onStoreChanged);
  }).bind(this);

  useMetadata(): LayerMetadata[] {
    return useSyncExternalStore(
      this.subscribeToMetadata,
      this.getCachedMetadata,
    );
  }
}
