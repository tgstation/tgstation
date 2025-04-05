import { SpriteData, SpriteEditorContextType } from './types';

export abstract class Tool {
  abstract icon: string;
  abstract name: string;
  abstract onMouseDown(
    context: SpriteEditorContextType,
    data: SpriteData,
    x: number,
    y: number,
    isRightClick?: boolean,
  ): boolean | void;
  onMouseMove?(
    context: SpriteEditorContextType,
    data: SpriteData,
    x: number,
    y: number,
  ): void;
  onMouseUp?(
    context: SpriteEditorContextType,
    data: SpriteData,
    x?: number,
    y?: number,
  ): void;
}
