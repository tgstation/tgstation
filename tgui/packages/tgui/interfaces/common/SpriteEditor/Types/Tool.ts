import type { SpriteData, SpriteEditorToolContext } from './types';

export abstract class Tool {
  abstract icon: string;
  abstract name: string;
  abstract onMouseDown(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x: number,
    y: number,
    isRightClick?: boolean,
  ): boolean | undefined;
  onMouseMove?(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x: number,
    y: number,
  ): void;
  onMouseUp?(
    context: SpriteEditorToolContext,
    data: SpriteData,
    x?: number,
    y?: number,
  ): void;
  cancel?();
}
