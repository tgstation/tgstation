import type { EditorColor, HSV, HSVA, RGB, RGBA } from './Types/types';

const rem = (n: number, d: number) => ((n % d) + d) % d;

export function rgb2hsv<T extends RGB>(rgb: T): Omit<T, 'r' | 'g' | 'b'> & HSV {
  let { r, g, b, ...rest } = rgb;
  r /= 255;
  g /= 255;
  b /= 255;
  const v = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = v - min;
  const s = v ? delta / v : undefined;
  let h: number | undefined;
  if (delta) {
    switch (v) {
      case r: {
        h = (g - b) / delta;
        break;
      }
      case g: {
        h = (b - r) / delta + 2;
        break;
      }
      case b: {
        h = (r - g) / delta + 4;
        break;
      }
    }
  }
  return {
    h: h && Math.round(rem(h, 6) * 60),
    s: s,
    v: v,
    ...rest,
  };
}

export function hsv2rgb<T extends HSV>(hsv: T): Omit<T, 'h' | 's' | 'v'> & RGB {
  let { h, s, v, ...rest } = hsv;
  if (h) {
    h = rem(h / 60, 6);
  }
  v *= 255;
  s ??= 0;
  let c = s * v;
  const x = Math.round(c * (1 - Math.abs(rem(h ?? 0, 2) - 1)));
  const m = Math.round(v - c);
  c = Math.round(c);
  v = Math.round(v);
  if (h === undefined || s === 0) {
    return { r: v, g: v, b: v, ...rest };
  }
  if (h >= 0 && h < 1) {
    return { r: c + m, g: x + m, b: m, ...rest };
  }
  if (h >= 1 && h < 2) {
    return { r: x + m, g: c + m, b: m, ...rest };
  }
  if (h >= 2 && h < 3) {
    return { r: m, g: c + m, b: x + m, ...rest };
  }
  if (h >= 3 && h < 4) {
    return { r: m, g: x + m, b: c + m, ...rest };
  }
  if (h >= 4 && h < 5) {
    return { r: x + m, g: m, b: c + m, ...rest };
  }
  if (h >= 5 && h < 6) {
    return { r: c + m, g: m, b: x + m, ...rest };
  }
  throw new Error(
    'Unreachable code - h is outside the range [0,6], which should not be possible.',
  );
}

export const hsva2hslString = (hsv: HSVA) => {
  const { h = 0, s, v, a } = hsv;
  const l = v * (1 - (s ?? 0) / 2);
  const sL = l === 0 || l === 1 ? 0 : (v - l) / Math.min(l, 1 - l);
  return `hsla(${h}, ${sL * 100}%, ${l * 100}%, ${a ?? 1})`;
};

export const isRgb = (color: EditorColor): color is RGB =>
  Object.keys(color).includes('r');
export const isHsv = (color: EditorColor): color is HSV =>
  Object.keys(color).includes('v');

export const parseHexColorString = (color: string): EditorColor => ({
  r: Number.parseInt(color.substring(1, 3), 16),
  g: Number.parseInt(color.substring(3, 5), 16),
  b: Number.parseInt(color.substring(5, 7), 16),
  a: color.length >= 9 ? Number.parseInt(color.substring(7, 9), 16) / 255 : 1,
});

type BothSpaces = RGBA & HSVA;

export const asBothSpaces = (color: EditorColor): BothSpaces =>
  isRgb(color)
    ? { ...color, ...rgb2hsv(color) }
    : { ...color, ...hsv2rgb(color) };

export const rgb2hexstring = (color: RGBA, alwaysIncludeAlpha = true) => {
  const { r, g, b, a = 1 } = color;
  return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}${
    alwaysIncludeAlpha || a !== 1
      ? Math.round(a * 255)
          .toString(16)
          .padStart(2, '0')
      : ''
  }`;
};

export const colorToCssString = (color: EditorColor) =>
  isRgb(color) ? rgb2hexstring(color, false) : hsva2hslString(color);

export const colorToHexString = (color: EditorColor) =>
  rgb2hexstring(isRgb(color) ? color : hsv2rgb(color));

export const colorsAreEqual = (a: EditorColor, b: EditorColor) => {
  if (isHsv(a) && isHsv(b)) {
    return a.h === b.h && a.s === b.s && a.v === b.v && a.a === b.a;
  }
  if (isHsv(a)) {
    a = hsv2rgb(a);
  }
  if (isHsv(b)) {
    b = hsv2rgb(b);
  }
  return a.r === b.r && a.g === b.g && a.b === b.b && a.a === b.a;
};
