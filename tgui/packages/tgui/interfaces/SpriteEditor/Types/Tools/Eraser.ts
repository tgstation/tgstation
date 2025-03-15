import { constrainToIconGrid } from '../../helpers';
import { Tool } from '../Tool';
import { LayerTransaction } from '../Transaction';
import { Dir, HSVA, Layer, RGBA } from '../types';
import { Workspace } from '../Workspace';

class EraserTransaction implements LayerTransaction {
  name = 'Eraser';
  layer: number;
  dir: Dir;
  points: Map<string, [number, number, RGBA | HSVA]> = new Map();

  constructor(dir: Dir, layer: number) {
    this.dir = dir;
    this.layer = layer;
  }

  addPoint(x: number, y: number, workspace: Workspace) {
    const hashKey = `${x},${y}`;
    if (this.points.has(hashKey)) return;
    const color = workspace.icon.getPixel(this.dir, this.layer, x, y)!;
    if (color.a === 0) return;
    this.points.set(`${x},${y}`, [x, y, color]);
    workspace.markMainCanvasDataDirty();
  }

  commit(workspace: Workspace) {
    this.points.values().forEach(([x, y]) =>
      workspace.icon.setPixel(this.dir, this.layer, x, y, {
        r: 0,
        g: 0,
        b: 0,
        a: 0,
      }),
    );
    workspace.markMainCanvasDataDirty();
  }

  undo(workspace: Workspace) {
    this.points
      .values()
      .forEach(([x, y, color]) =>
        workspace.icon.setPixel(this.dir, this.layer, x, y, color),
      );
    workspace.markMainCanvasDataDirty();
  }

  applyPreview(layer: Layer) {
    this.points
      .values()
      .forEach(([x, y]) => (layer[y][x] = { r: 0, g: 0, b: 0, a: 0 }));
  }
}

export class Eraser extends Tool {
  icon = 'eraser';
  name = 'Eraser';
  currentTransaction: EraserTransaction | null;
  onMouseDown(
    workspace: Workspace,
    x: number,
    y: number,
    isRightClick: boolean,
  ) {
    const { icon, selectedDir, selectedLayer } = workspace;
    const [px, py, inBounds] = constrainToIconGrid(x, y, icon);
    if (!inBounds || isRightClick) return false;
    workspace.pendingTransaction = this.currentTransaction =
      new EraserTransaction(selectedDir, selectedLayer);
    this.currentTransaction.addPoint(px, py, workspace);
    return true;
  }
  onMouseMove(workspace: Workspace, x: number, y: number) {
    const { icon } = workspace;
    const [px, py, inBounds] = constrainToIconGrid(x, y, icon);
    if (!inBounds) return;
    this.currentTransaction!.addPoint(px, py, workspace);
  }
  onMouseUp(workspace: Workspace, x: number, y: number) {
    const transaction = this.currentTransaction!;
    this.currentTransaction = null;
    if (transaction.points.size > 0) {
      workspace.commitTransaction();
    } else {
      workspace.discardPendingTransaction();
    }
  }
}
