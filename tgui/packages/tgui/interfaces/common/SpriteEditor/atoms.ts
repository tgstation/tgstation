import { atom } from 'jotai';
import { sendAct as act } from 'tgui/events/act';
import { colorToHexString } from './colorSpaces';
import type { Tool } from './Types/Tool';
import { Bucket } from './Types/Tools/Bucket';
import { Eraser } from './Types/Tools/Eraser';
import { Eyedropper } from './Types/Tools/Eyedropper';
import { Pencil } from './Types/Tools/Pencil';
import {
  Dir,
  type EditorColor,
  type SpriteEditorToolCancelContext,
  type StringLayer,
} from './Types/types';

export const colorsAtom = atom<EditorColor[]>([]);
export const currentColorInternalAtom = atom<EditorColor>({
  r: 255,
  g: 255,
  b: 255,
});
export const onSelectServerColorAtom = atom<string | undefined>(undefined);
export const currentColorAtom = atom<EditorColor, [EditorColor], void>(
  (get) => get(currentColorInternalAtom),
  (get, set, color) => {
    if (!color) {
      return;
    }
    const onSetServerColor = get(onSelectServerColorAtom);
    if (onSetServerColor) {
      act(onSetServerColor, { color: colorToHexString(color) });
    }
    set(currentColorInternalAtom, color);
  },
);

export const tools: Tool[] = [
  new Pencil(),
  new Eraser(),
  new Eyedropper(),
  new Bucket(),
];

const currentToolInternalAtom = atom(tools[0]);
export const currentToolAtom = atom<
  Tool,
  [Tool, SpriteEditorToolCancelContext],
  void
>(
  (get) => get(currentToolInternalAtom),
  (get, set, tool, context) => {
    if (!tool) {
      return;
    }
    const oldTool = get(currentToolInternalAtom);
    if (oldTool !== tool) {
      oldTool?.cancel?.(context);
    }
    set(currentToolInternalAtom, tool);
  },
);
export const dirAtom = atom(Dir.SOUTH);
export const layerAtom = atom(0);
export const previewLayerAtom = atom<number | undefined>();
export const previewDataAtom = atom<StringLayer | undefined>();
