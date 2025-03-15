import { copyStack, fillBy, matrix } from '../helpers';
import { EditorColor } from './types';
import { Dir, IconData, IconDirCount, LayerStack } from './types';

export class Icon {
  width: number;
  height: number;
  layerCount: number;
  inner: IconData;

  constructor(width: number = 32, height: number = 32, dirs: IconDirCount = 1) {
    this.width = width;
    this.height = height;
    this.layerCount = 1;
    switch (dirs) {
      case 1: {
        this.inner = {
          dirs: 1,
          data: matrix(() => ({ r: 0, g: 0, b: 0, a: 0 }), width, height, 1)(),
        };
        break;
      }
      case 4: {
        this.inner = {
          dirs: 4,
          data: new Map(
            [Dir.SOUTH, Dir.NORTH, Dir.EAST, Dir.WEST].map((dir) => [
              dir,
              matrix(() => ({ r: 0, g: 0, b: 0, a: 0 }), width, height, 1)(),
            ]),
          ),
        };
        break;
      }
    }
  }

  resize(newWidth: number, newHeight: number) {
    const oldWidth = this.width;
    const oldHeight = this.height;
    const resizeRow = (row: EditorColor[]) => {
      row.length = newWidth;
      if (newWidth > oldWidth) {
        fillBy(row, () => ({ r: 0, g: 0, b: 0, a: 0 }), oldWidth);
      }
    };
    (this.inner.dirs === 1
      ? [this.inner.data]
      : this.inner.data.values()
    ).forEach((stack) => {
      stack.forEach((layer) => {
        if (newHeight > oldHeight) {
          layer.forEach(resizeRow);
          layer.length = newHeight;
          fillBy(
            layer,
            matrix(() => ({ r: 0, g: 0, b: 0, a: 0 }), newWidth),
            oldHeight,
          );
        } else if (newHeight < oldHeight) {
          layer.length = newHeight;
          layer.forEach(resizeRow);
        } else {
          layer.forEach(resizeRow);
        }
      });
    });
  }

  setLayerCount(newCount: number) {
    const oldLayerCount = this.layerCount;
    const { dirs, data } = this.inner;
    (dirs === 1 ? [data] : data.values()).forEach((stack) => {
      stack.length = newCount;
      if (newCount > oldLayerCount) {
        fillBy(
          stack,
          matrix(() => ({ r: 0, g: 0, b: 0, a: 0 }), this.width, this.height),
          oldLayerCount,
        );
      }
    });
  }

  getStack(dir: Dir) {
    const { dirs, data } = this.inner;
    return dirs === 1 ? data : data.get(dir);
  }

  stacks(): [Dir, LayerStack][] {
    const { dirs, data } = this.inner;
    return dirs === 1 ? [[Dir.SOUTH, data]] : data.entries().toArray();
  }

  setDirCount(newCount: IconDirCount) {
    const { data } = this.inner;
    switch (newCount) {
      case 1:
        this.inner = {
          dirs: 1,
          data: data instanceof Map ? data.get(Dir.SOUTH)! : data,
        };
        break;
      case 4: {
        const southData = data instanceof Map ? data.get(Dir.SOUTH)! : data;
        this.inner = {
          dirs: 4,
          data:
            data instanceof Map
              ? data
              : new Map<Dir, LayerStack>([
                  [Dir.SOUTH, data],
                  [Dir.NORTH, copyStack(southData)],
                  [Dir.EAST, copyStack(southData)],
                  [Dir.WEST, copyStack(southData)],
                ]),
        };
        break;
      }
    }
  }

  getPixel(dir: Dir, layer: number, x: number, y: number) {
    if (layer < 0 || layer > this.layerCount) return;
    if (x < 0 || x > this.width) return;
    if (y < 0 || y > this.height) return;
    const stack =
      this.inner.dirs === 1 ? this.inner.data : this.inner.data.get(dir);
    if (!stack) return;
    return stack[layer][y][x];
  }

  setPixel(dir: Dir, layer: number, x: number, y: number, color: EditorColor) {
    if (layer < 0 || layer > this.layerCount) return;
    if (x < 0 || x > this.width) return;
    if (y < 0 || y > this.height) return;
    const stack =
      this.inner.dirs === 1 ? this.inner.data : this.inner.data.get(dir);
    if (!stack) return;
    stack[layer][y][x] = color;
  }
}
