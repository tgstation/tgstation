import type { Dispatch, SetStateAction, useSyncExternalStore } from 'react';
import type { Box } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export type RGB = {
  r: number;
  g: number;
  b: number;
};

export type RGBA = RGB & { a?: number };

export type HSV = {
  h?: number;
  s?: number;
  v: number;
};

export type HSVA = HSV & { a?: number };

export type EditorColor = HSVA | RGBA;

export enum Dir {
  NORTH = 1,
  SOUTH = 2,
  EAST = 4,
  WEST = 8,
}

export type IconDirCount = 1 | 4;
export type Layer = EditorColor[][];
export type LayerStack = Layer[];
type IconData1Dir = {
  dirs: 1;
  data: LayerStack;
};
type IconData4Dirs = {
  dirs: 4;
  data: Map<Dir, LayerStack>;
};
export type IconData = IconData1Dir | IconData4Dirs;

export type WindowEventHandler = (event: MouseEvent) => void;

export type ClickAndDragEventHandler<T> = (
  event: MouseEvent,
  ref: React.Ref<T>,
) => void;

export type IncludeOrOmitEntireType<T, V> = V | (T & V);

type PickByType<T, V> = {
  [K in keyof T as T[K] extends V ? K : never]: T[K];
};

export type InlineStyle = Pick<Parameters<typeof Box>[0], 'style'>;

export type BorderStyleProps = Omit<
  React.CSSProperties,
  keyof PickByType<
    {
      [K in keyof Required<React.CSSProperties>]: K extends `border${string}`
        ? React.CSSProperties[K]
        : never;
    },
    never
  >
>;

export type SubscribeFn = Parameters<typeof useSyncExternalStore>[0];

export type StringLayer = string[][];

export type SpriteDataLayer = {
  name: string;
  visible: BooleanLike;
  data: {
    [key in Dir]: key extends Dir.SOUTH ? StringLayer : StringLayer | undefined;
  };
};

export type SpriteData = {
  width: number;
  height: number;
  dirs: IconDirCount;
  backdrop: string;
  layers: SpriteDataLayer[];
};

export enum SpriteEditorColorMode {
  Rgba = 'rgba',
  Rgb = 'rgb',
  Greyscale = 'greyscale',
}

export enum SpriteEditorToolFlags {
  Pencil = 1 << 0,
  Eraser = 1 << 1,
  Dropper = 1 << 2,
  Bucket = 1 << 3,
  All = (1 << 4) - 1,
}

export type ServerColorData = {
  serverSelectedColor: string;
  serverPalette: string[];
  maxServerColors: number;
  onSelectServerColor?: string;
  onAddServerColor?: string;
  onRemoveServerColor?: string;
};

export type SpriteEditorData = IncludeOrOmitEntireType<
  ServerColorData,
  {
    colorMode: SpriteEditorColorMode;
    undoStack: string[];
    redoStack: string[];
    toolFlags?: SpriteEditorToolFlags;
    sprite: SpriteData;
  }
>;

export type SpriteEditorToolContext = {
  currentColor: EditorColor;
  setCurrentColor: Dispatch<SetStateAction<EditorColor>>;
  selectedDir: Dir;
  selectedLayer: number;
  setPreviewLayer: Dispatch<SetStateAction<number | undefined>>;
  setPreviewData: Dispatch<SetStateAction<StringLayer | undefined>>;
};
