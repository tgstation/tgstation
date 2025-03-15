import { hsv2rgb, isRgb } from '../../colorSpaces';
import { constrainToIconGrid } from '../../helpers';
import { Tool } from '../Tool';
import { LayerTransaction } from '../Transaction';
import { EditorColor } from '../types';
import { Dir, HSVA, Layer, RGBA } from '../types';
import { Workspace } from '../Workspace';

class PencilTransaction implements LayerTransaction {
  name = 'Pencil';
  color: HSVA | RGBA;
  layer: number;
  dir: Dir;
  points: Map<string, [number, number, RGBA | HSVA]> = new Map();

  constructor(dir: Dir, layer: number, color: EditorColor) {
    this.dir = dir;
    this.layer = layer;
    this.color = color;
  }

  addPoint(x: number, y: number, workspace: Workspace) {
    const hashKey = `${x},${y}`;
    if (this.points.has(hashKey)) return;
    this.points.set(`${x},${y}`, [
      x,
      y,
      workspace.icon.getPixel(this.dir, this.layer, x, y)!,
    ]);
    workspace.markMainCanvasDataDirty();
  }

  commit(workspace: Workspace) {
    this.points
      .values()
      .forEach(([x, y]) =>
        workspace.icon.setPixel(this.dir, this.layer, x, y, this.color),
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
    const { a = 1 } = this.color;
    this.points.values().forEach(
      ([x, y]) =>
        (layer[y][x] = {
          ...(isRgb(this.color) ? this.color : hsv2rgb(this.color)),
          a,
        }),
    );
  }
}

export class Pencil extends Tool {
  icon = 'pencil';
  name = 'Pencil';
  currentTransaction: PencilTransaction | null;
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
      new PencilTransaction(
        selectedDir,
        selectedLayer,
        workspace.getPrimaryColor!(),
      );
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
    this.currentTransaction = null;
    workspace.commitTransaction();
  }
}
