import { atom } from 'jotai';
import { sendAct as act } from 'tgui/events/act';
import { colorToHexString } from './colorSpaces';
import type { Tool } from './Types/Tool';
import { Bucket } from './Types/Tools/Bucket';
import { Eraser } from './Types/Tools/Eraser';
import { Eyedropper } from './Types/Tools/Eyedropper';
import { Pencil } from './Types/Tools/Pencil';
import { Dir, type EditorColor, type StringLayer } from './Types/types';

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

export const currentToolAtom = atom(tools[0]);
export const dirAtom = atom(Dir.SOUTH);
export const layerAtom = atom(0);
export const previewLayerAtom = atom<number | undefined>();
export const previewDataAtom = atom<StringLayer | undefined>();
