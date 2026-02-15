import { useCallback } from 'react';
import { sendAct as act } from 'tgui/events/act';
import { parseHexColorString } from '../../colorSpaces';
import {
  bresenhamLine,
  constrainToIconGrid,
  copyLayer,
  getDataPixel,
} from '../../helpers';
import { Tool } from '../Tool';
import type { LayerTransaction } from '../Transaction';
import type {
  Dir,
  SpriteData,
  SpriteEditorToolCancelContext,
  SpriteEditorToolContext,
  StringLayer,
} from '../types';

class EraserTransaction implements LayerTransaction {
  name = 'Eraser';
  layer: number;
  dir: Dir;
  points: Map<string, [number, number]> = new Map();

  constructor(dir: Dir, layer: number) {
    this.dir = dir;
    this.layer = layer;
  }

  addPoint(x: number, y: number, color: string) {
    const hashKey = `${x},${y}`;
    if (this.points.has(hashKey)) return;
    if (parseHexColorString(color).a === 0) return;
    this.points.set(`${x},${y}`, [x, y]);
  }

  getPreviewLayer(layer: StringLayer) {
    const outLayer = copyLayer(layer);
    this.points.values().forEach(([x, y]) => {
      outLayer[y][x] = '#00000000';
    });
    return outLayer;
  }

  commit() {
    act('spriteEditorCommand', {
      command: 'transaction',
      transaction: {
        type: 'eraser',
        name: 'Eraser',
        layer: this.layer + 1,
        dir: `${this.dir}`,
        points: this.points.values().toArray(),
      },
    });
  }
}

export class Eraser extends Tool {
  icon = 'eraser';
  name = 'Eraser';
  currentTransaction: EraserTransaction | null;
  lastPoint: [number, number] | null = null;

  onMouseDown(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x: number,
    y: number,
    isRightClick: boolean,
  ) {
    const { selectedDir, selectedLayer, setPreviewLayer, setPreviewData } =
      context;
    const { width, height, layers } = data;
    const [px, py, inBounds] = constrainToIconGrid(x, y, width, height);
    if (isRightClick) return;
    this.currentTransaction = new EraserTransaction(selectedDir, selectedLayer);
    if (inBounds) {
      this.currentTransaction.addPoint(
        px,
        py,
        getDataPixel(data, selectedLayer, selectedDir, px, py),
      );
    }
    this.lastPoint = [px, py];
    setPreviewLayer(selectedLayer);
    setPreviewData(
      this.currentTransaction.getPreviewLayer(
        layers[selectedLayer].data[selectedDir]!,
      ),
    );
    return true;
  }

  onMouseMove(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x: number,
    y: number,
  ) {
    const { currentTransaction, lastPoint } = this;
    if (!currentTransaction) return;
    const { selectedDir, selectedLayer, setPreviewData } = context;
    const { width, height, layers } = data;
    const { dir, layer } = currentTransaction;
    const [px, py] = constrainToIconGrid(x, y, width, height);
    const [opx, opy] = lastPoint!;
    bresenhamLine(
      opx,
      opy,
      px,
      py,
      useCallback(
        (x, y) => {
          if (x < 0 || x >= width || y < 0 || y >= height) {
            return;
          }
          currentTransaction.addPoint(
            x,
            y,
            getDataPixel(data, selectedLayer, selectedDir, x, y),
          );
        },
        [currentTransaction, width, height, selectedLayer, selectedDir, data],
      ),
    );
    this.lastPoint = [px, py];
    setPreviewData(
      currentTransaction.getPreviewLayer(layers[layer].data[dir]!),
    );
  }

  onMouseUp(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x: number,
    y: number,
  ) {
    if (!this.currentTransaction) return;
    if (this.currentTransaction.points.size !== 0) {
      this.currentTransaction.commit();
    }
    this.currentTransaction.commit();
    this.currentTransaction = null;
  }

  cancel(context: SpriteEditorToolCancelContext) {
    this.currentTransaction = null;
    const { setPreviewLayer, setPreviewData } = context;
    setPreviewLayer(undefined);
    setPreviewData(undefined);
    this.lastPoint = null;
  }
}
