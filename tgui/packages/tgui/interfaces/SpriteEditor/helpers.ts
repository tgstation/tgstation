import { useEffect, useMemo, useState, useSyncExternalStore } from 'react';
import { capitalizeFirst } from 'tgui-core/string';

import { Icon } from './Types/Icon';
import { ClickAndDragEventHandler, Layer, LayerStack } from './Types/types';

export function matrix<T>(initializer: () => T, ...dimensions: number[]) {
  return dimensions.reduce(
    (generator: () => any, dimension) => () =>
      Array.from({ length: dimension }, generator),
    () => initializer(),
  );
}
export function fillBy<T>(
  array: T[],
  fn: (value: T, index: number, array: T[]) => T,
  start?: number,
  end?: number,
) {
  array
    .keys()
    .toArray()
    .slice(start, end)
    .forEach((i) => {
      array[i] = fn(array[i], i, array);
    });
}

export const lerp = (a: number, b: number, t: number) => a + (b - a) * t;

export const invLerp = (a: number, b: number, x: number) => (x - a) / (b - a);

export function useResizeObserver<T extends Element>(
  ref: React.RefObject<T>,
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
  ref: React.RefObject<HTMLElement>,
): [number, number] => {
  const [dimensions, setDimensions] = useState<[number, number]>([0, 0]);
  useResizeObserver(ref, (element) => {
    const { width, height } = element.contentRect;
    setDimensions([width, height]);
  });
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
  icon: Icon,
): [number, number, boolean] => {
  const { width, height } = icon;
  return [
    Math.floor(x),
    Math.floor(y),
    x >= 0 && x < width && y >= 0 && y < height,
  ];
};

export const localizeCoords = (
  ev: MouseEvent,
  ref: React.RefObject<HTMLCanvasElement>,
  icon: Icon,
) => {
  const { clientX, clientY } = ev;
  const { width: imageWidth, height: imageHeight } = icon;
  const { top, left, width, height } = ref.current!.getBoundingClientRect();
  return [
    lerp(0, imageWidth, invLerp(0, width, clientX - left)),
    lerp(0, imageHeight, invLerp(0, height, clientY - top)),
  ];
};

export function typedCapitalize<T extends string>(string: T): Capitalize<T> {
  return capitalizeFirst(string) as Capitalize<T>;
}

type StoreStateStore<T> = {
  value: T;
  onChange: Set<() => void>;
};

type StoreStateWithDispatch<T> = [
  () => T,
  (newValue: T | ((oldValue: T) => T)) => void,
  () => T,
];

export function useStoreState<T>(
  initial: T | (() => T),
): StoreStateWithDispatch<T> {
  return useMemo(() => {
    const store: StoreStateStore<T> = {
      value: typeof initial === 'function' ? (initial as () => T)() : initial,
      onChange: new Set(),
    };
    const subscribe = (onStoreChanged: () => void) => {
      store.onChange.add(onStoreChanged);
      return () => store.onChange.delete(onStoreChanged);
    };
    const getSnapshot = () => store.value;
    return [
      () => useSyncExternalStore(subscribe, getSnapshot),
      (newValue: T | ((oldValue: T) => T)) => {
        store.value =
          typeof newValue === 'function'
            ? (newValue as (oldValue: T) => T)(store.value)
            : newValue;
        store.onChange.forEach((cb) => cb());
      },
      getSnapshot,
    ];
  }, []);
}

export const copyLayer = (layer: Layer) => [...layer.map((row) => [...row])];

export const copyStack = (stack: LayerStack) => [...stack.map(copyLayer)];

export const bytes2Base64UrlSafe = async (data: Uint8Array) =>
  (
    await new Promise<string>((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result as string);
      reader.onerror = () => reject(reader.result);
      reader.readAsDataURL(
        new File([data], '', { type: 'application/octet-stream' }),
      );
    })
  ).replace('data:application/octet-stream;base64,', '');
