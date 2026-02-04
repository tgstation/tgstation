import { normal } from 'color-blend';
import { useCallback, useEffect, useState } from 'react';

import { hsv2rgb, isRgb, parseHexColorString } from './colorSpaces';
import type {
  ClickAndDragEventHandler,
  Dir,
  EditorColor,
  Layer,
  RGBA,
  ServerColorData,
  SpriteData,
  SpriteEditorData,
  StringLayer,
} from './Types/types';

export function matrix<T>(initializer: () => T, ...dimensions: number[]) {
  return dimensions.reduce(
    (generator: () => any, dimension) => () =>
      Array.from({ length: dimension }, generator),
    () => initializer(),
  );
}

export const lerp = (a: number, b: number, t: number) => a + (b - a) * t;

export const invLerp = (a: number, b: number, x: number) => (x - a) / (b - a);

export function useResizeObserver<T extends Element>(
  ref: React.RefObject<T | null>,
  observerCallback: (element: ResizeObserverEntry) => void,
) {
  useEffect(() => {
    const observer = new ResizeObserver((entries) => {
      if (entries.length) observerCallback(entries[0]);
    });
    const current = ref.current;
    if (!current) return;
    observer.observe(current);
    return () => observer.unobserve(current);
  }, [ref, observerCallback]);
}

export const useDimensions = (
  ref: React.RefObject<HTMLElement | null>,
): [number, number] => {
  const [dimensions, setDimensions] = useState<[number, number]>([0, 0]);
  useResizeObserver(
    ref,
    useCallback(
      (element) => {
        const { width, height } = element.contentRect;
        setDimensions([width, height]);
      },
      [setDimensions],
    ),
  );
  return dimensions;
};

export function useClickAndDragEventHandler<T>(
  ref: React.Ref<T>,
  onMouseDown?: ClickAndDragEventHandler<T>,
  onMouseMove?: ClickAndDragEventHandler<T>,
  onMouseUp?: ClickAndDragEventHandler<T>,
): (MouseEvent) => void {
  const moveHandler = (ev: MouseEvent) => onMouseMove?.(ev, ref);
  const upHandler = (ev: MouseEvent) => {
    onMouseUp?.(ev, ref);
    ev.preventDefault();
    window.removeEventListener('mousemove', moveHandler);
  };
  return (ev: MouseEvent) => {
    onMouseDown?.(ev, ref);
    if (ev.defaultPrevented) return;
    ev.preventDefault();
    window.addEventListener('mousemove', moveHandler);
    window.addEventListener('mouseup', upHandler, { once: true });
  };
}

export const constrainToIconGrid = (
  x: number,
  y: number,
  width: number,
  height: number,
): [number, number, boolean] => {
  return [
    Math.floor(x),
    Math.floor(y),
    x >= 0 && x < width && y >= 0 && y < height,
  ];
};

export const localizeCoords = (
  ev: MouseEvent,
  ref: React.RefObject<HTMLCanvasElement | null>,
  imageWidth: number,
  imageHeight: number,
) => {
  const { clientX, clientY } = ev;
  const { top, left, width, height } = ref.current!.getBoundingClientRect();
  return [
    lerp(0, imageWidth, invLerp(0, width, clientX - left)),
    lerp(0, imageHeight, invLerp(0, height, clientY - top)),
  ];
};

export const getDataPixel = (
  data: SpriteData,
  layer: number,
  dir: Dir,
  x: number,
  y: number,
) => data.layers[layer].data[dir]![y][x] ?? '#00000000';

export const getFlattenedSpriteDir = (
  data: SpriteData,
  dir: Dir,
  selectedLayer: number,
  previewLayer?: number,
  previewData?: StringLayer,
  backdrop: EditorColor = { r: 0, g: 0, b: 0, a: 0 },
) => {
  const { width, height, layers } = data;
  const output = matrix(
    () => Object.assign({}, backdrop),
    width,
    height,
  )() as Layer;
  layers.forEach(({ data: layer, visible }, i) => {
    if (!visible && i !== selectedLayer) return;
    (previewLayer === i ? previewData : layer[dir])!.forEach((row, y) => {
      row.forEach((frontPixelstring, x) => {
        const frontPixel = parseHexColorString(frontPixelstring);
        const backPixel = output[y][x];
        const outPixel: RGBA = normal(
          { a: 1, ...(isRgb(backPixel) ? backPixel : hsv2rgb(backPixel)) },
          { a: 1, ...(isRgb(frontPixel) ? frontPixel : hsv2rgb(frontPixel)) },
        );
        if (outPixel.a === 1) delete outPixel.a;
        output[y][x] = outPixel;
      });
    });
  });
  return output;
};

export function copyLayer<T>(layer: T[][]) {
  return [...layer.map((row) => [...row])];
}

export function hasServerColorData(
  data: SpriteEditorData,
): data is ServerColorData & SpriteEditorData {
  return Object.hasOwn(data, 'serverPalette');
}
