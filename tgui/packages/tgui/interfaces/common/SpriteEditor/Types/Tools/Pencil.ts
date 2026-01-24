import { sendAct as act } from 'tgui/events/act';
import { colorToHexString } from '../../colorSpaces';
import { constrainToIconGrid, copyLayer } from '../../helpers';
import { Tool } from '../Tool';
import type { LayerTransaction } from '../Transaction';
import type {
  Dir,
  SpriteData,
  SpriteEditorToolContext,
  StringLayer,
} from '../types';

class PencilTransaction implements LayerTransaction {
  color: string;
  layer: number;
  dir: Dir;
  points: Map<string, [number, number]> = new Map();

  constructor(dir: Dir, layer: number, color: string) {
    this.dir = dir;
    this.layer = layer;
    this.color = color;
  }

  addPoint(x: number, y: number) {
    const hashKey = `${x},${y}`;
    if (this.points.has(hashKey)) return;
    this.points.set(`${x},${y}`, [x, y]);
  }

  getPreviewLayer(layer: StringLayer) {
    const outLayer = copyLayer(layer);
    this.points.values().forEach(([x, y]) => {
      outLayer[y][x] = this.color;
    });
    return outLayer;
  }

  commit() {
    act('spriteEditorCommand', {
      command: 'transaction',
      transaction: {
        type: 'pencil',
        name: 'Pencil',
        layer: this.layer + 1,
        dir: `${this.dir}`,
        color: this.color,
        points: this.points.values().toArray(),
      },
    });
  }
}

export class Pencil extends Tool {
  icon = 'pencil';
  name = 'Pencil';
  currentTransaction: PencilTransaction | null;

  onMouseDown(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x: number,
    y: number,
    isRightClick: boolean,
  ) {
    const {
      selectedDir,
      selectedLayer,
      currentColor,
      setPreviewLayer,
      setPreviewData,
    } = context;
    const { width, height, layers } = data;
    const [px, py, inBounds] = constrainToIconGrid(x, y, width, height);
    if (!inBounds || isRightClick) return;
    this.currentTransaction = new PencilTransaction(
      selectedDir,
      selectedLayer,
      colorToHexString(currentColor),
    );
    this.currentTransaction.addPoint(px, py);
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
    const { currentTransaction } = this;
    if (!currentTransaction) return;
    const { setPreviewData } = context;
    const { width, height, layers } = data;
    const { dir, layer } = currentTransaction;
    const [px, py, inBounds] = constrainToIconGrid(x, y, width, height);
    if (!inBounds) return;
    currentTransaction.addPoint(px, py);
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
    const { setPreviewLayer, setPreviewData } = context;
    setPreviewLayer(undefined);
    setPreviewData(undefined);
    this.currentTransaction.commit();
    this.currentTransaction = null;
  }
  cancel() {
    this.currentTransaction = null;
  }
}
