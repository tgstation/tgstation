import { Dispatch, SetStateAction, useSyncExternalStore } from 'react';
import { Box } from 'tgui-core/components';

import { Tool } from './Tool';

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

type PickByType<T, V> = {
  [K in keyof T as T[K] extends V ? K : never]: T[K];
};

type Substitute<T, K extends keyof T, U extends T[K]> = Omit<T, K> & {
  [key in K]: U;
};

type WithDispatch<T, K extends string & keyof T> = T & {
  [key in K as `set${Capitalize<key>}`]: Dispatch<SetStateAction<T[key]>>;
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

export type SerializedIconState = {
  name: string;
  dirs: IconDirCount;
  delay?: number[];
  rewind?: boolean;
  movement?: boolean;
  loop?: number;
  samples: Uint8Array | string;
};

export type SerializedIcon = {
  width: number;
  height: number;
  states: SerializedIconState[];
};

export type StringLayer = string[][];

export type SpriteDataLayer = {
  name: string;
  data: {
    [key in Dir]: key extends Dir.SOUTH ? StringLayer : StringLayer | undefined;
  };
};

export type SpriteData = {
  width: number;
  height: number;
  dirs: IconDirCount;
  layers: SpriteDataLayer[];
};

export type SpriteEditorData = {
  undoStack: string[];
  redoStack: string[];
  sprite: SpriteData;
};

export type SpriteEditorContextType = {
  colors: EditorColor[];
  setColors: Dispatch<SetStateAction<EditorColor[]>>;
  currentColor: EditorColor;
  setCurrentColor: Dispatch<SetStateAction<EditorColor>>;
  tools: Tool[];
  currentTool: Tool;
  setCurrentTool: Dispatch<SetStateAction<Tool>>;
  selectedDir: Dir;
  setSelectedDir: Dispatch<SetStateAction<Dir>>;
  selectedLayer: number;
  setSelectedLayer: Dispatch<SetStateAction<number>>;
  visibleLayers: boolean[];
  setVisibleLayers: Dispatch<SetStateAction<boolean[]>>;
  previewLayer?: number;
  setPreviewLayer: Dispatch<SetStateAction<number | undefined>>;
  previewData?: StringLayer;
  setPreviewData: Dispatch<SetStateAction<StringLayer | undefined>>;
};
