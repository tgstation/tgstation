import { normal } from 'color-blend';

import { hsv2rgb, isRgb } from '../colorSpaces';
import { copyLayer, matrix } from '../helpers';
import { Transaction } from './Transaction';
import { Dir, Layer, RGBA } from './types';
import { LayerMetadata, Workspace } from './Workspace';

abstract class MoveLayerTransaction implements Transaction {
  name: string;
  index: number;
  abstract indexOffset: number;
  constructor(workspace: Workspace, index: number) {
    this.setName(workspace.metadata[index].name);
    this.index = index;
  }
  setName(layerName: string) {
    this.name = `Move ${layerName}`;
  }
  swapLayers(workspace: Workspace) {
    const { index, indexOffset } = this;
    const destIndex = index + indexOffset;
    const { metadata, icon } = workspace;
    [metadata[destIndex], metadata[index]] = [
      metadata[index],
      metadata[destIndex],
    ];
    icon
      .stacks()
      .forEach(
        ([_, stack]) =>
          ([stack[destIndex], stack[index]] = [stack[index], stack[destIndex]]),
      );
    if (metadata[destIndex].visible && metadata[index].visible) {
      workspace.markMainCanvasDataDirty();
    }
    workspace.markMetadataChanged();
  }
  commit = this.swapLayers;
  undo = this.swapLayers;
}

export class MoveLayerUpTransaction extends MoveLayerTransaction {
  indexOffset = 1;
}

export class MoveLayerDownTransaction extends MoveLayerTransaction {
  indexOffset = -1;
}

export class FlattenLayerTransaction implements Transaction {
  name: string;
  index: number;
  oldTop: Map<Dir, Layer>;
  oldMetadata: LayerMetadata;
  oldBottom: Map<Dir, Layer>;
  constructor(workspace: Workspace, index: number) {
    const { icon, metadata } = workspace;
    const stacks = icon.stacks();
    this.index = index;
    this.oldTop = new Map(
      stacks.map(([dir, stack]) => [dir, copyLayer(stack[index])]),
    );
    this.oldMetadata = metadata[index];
    this.oldBottom = new Map(
      stacks.map(([dir, stack]) => [dir, copyLayer(stack[index - 1])]),
    );
    this.name = `Flatten ${this.oldMetadata.name}`;
  }
  commit(workspace: Workspace) {
    const { index, oldTop } = this;
    const { icon, metadata } = workspace;
    const destIndex = this.index - 1;
    icon.stacks().forEach(([dir, stack]) => {
      const topLayer = oldTop.get(dir)!;
      const bottomLayer = stack[destIndex];
      bottomLayer.forEach((row, y) =>
        row.forEach((bottomPixel, x) => {
          const topPixel = topLayer[y][x];
          const topRgb: Required<RGBA> = {
            ...(isRgb(topPixel) ? topPixel : hsv2rgb(topPixel)),
            a: topPixel.a ?? 1,
          };
          const bottomRgb: Required<RGBA> = {
            ...(isRgb(bottomPixel) ? bottomPixel : hsv2rgb(bottomPixel)),
            a: bottomPixel.a ?? 1,
          };
          bottomLayer[y][x] = normal(bottomRgb, topRgb);
        }),
      );
      stack.splice(index, 1);
      workspace.markMetadataChanged();
    });
    metadata.splice(index, 1);
    if (metadata[destIndex].visible || this.oldMetadata.visible) {
      workspace.markMainCanvasDataDirty();
    }
    workspace.markMetadataChanged();
  }
  undo(workspace: Workspace) {
    const { index, oldTop, oldMetadata, oldBottom } = this;
    const { icon, metadata } = workspace;
    const destIndex = index - 1;
    icon
      .stacks()
      .forEach(([dir, stack]) =>
        stack.splice(destIndex, 1, oldBottom.get(dir)!, oldTop.get(dir)!),
      );
    workspace.markMetadataChanged();
    metadata.splice(index, 0, oldMetadata);
    if (metadata[destIndex].visible || oldMetadata.visible) {
      workspace.markMainCanvasDataDirty();
    }
    workspace.markMetadataChanged();
  }
}

export class RenameLayerTransaction implements Transaction {
  name: string;
  index: number;
  newName: string;
  oldName: string;
  constructor(workspace: Workspace, index: number, name: string) {
    this.index = index;
    this.newName = name;
    this.oldName = workspace.metadata[index].name;
    this.name = `Rename ${this.oldName} to ${this.newName}`;
  }
  commit(workspace: Workspace) {
    workspace.metadata[this.index].name = this.newName;
    workspace.markMetadataChanged();
  }
  undo(workspace: Workspace) {
    workspace.metadata[this.index].name = this.oldName;
    workspace.markMetadataChanged();
  }
}

export class DeleteLayerTransaction implements Transaction {
  name: string;
  index: number;
  layer: Map<Dir, Layer>;
  oldMetadata: LayerMetadata;
  constructor(workspace: Workspace, index: number) {
    const { icon, metadata } = workspace;
    this.index = index;
    this.oldMetadata = metadata[index];
    this.layer = new Map(
      icon.stacks().map(([dir, stack]) => [dir, copyLayer(stack[index])]),
    );
    this.name = `Delete ${this.oldMetadata.name}`;
  }
  commit(workspace: Workspace) {
    const { icon, metadata } = workspace;
    const { index, oldMetadata } = this;
    icon.stacks().forEach(([_, stack]) => stack.splice(index, 1));
    metadata.splice(index, 1);
    if (oldMetadata.visible) {
      workspace.markMainCanvasDataDirty();
    }
    workspace.markMetadataChanged();
  }
  undo(workspace: Workspace) {
    const { icon, metadata } = workspace;
    const { index, layer, oldMetadata } = this;
    icon
      .stacks()
      .forEach(([dir, stack]) => stack.splice(index, 0, layer.get(dir)!));
    metadata.splice(index, 0, oldMetadata);
    if (oldMetadata.visible) {
      workspace.markMainCanvasDataDirty();
    }
    workspace.markMetadataChanged();
  }
}

export class AddLayerTransaction implements Transaction {
  name = 'Add Layer';
  commit(workspace: Workspace) {
    const { icon, metadata } = workspace;
    const { width, height } = icon;
    metadata.push({ name: 'New Layer', visible: true });
    icon
      .stacks()
      .forEach(([_, stack]) =>
        stack.push(matrix(() => ({ r: 0, g: 0, b: 0, a: 0 }), width, height)()),
      );
    workspace.markMetadataChanged();
  }
  undo(workspace: Workspace) {
    const { icon, metadata } = workspace;
    metadata.splice(-1, 1);
    icon.stacks().forEach(([_, stack]) => stack.splice(-1, 1));
    workspace.markMetadataChanged();
  }
}
