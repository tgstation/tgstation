import { HSV, HSVA, RGB, RGBA, WithOptional } from './Types/types';

const rem = (n: number, d: number) => ((n % d) + d) % d;

export const rgb2hsv = (rgb: RGB): WithOptional<HSV, 'h' | 's'> => {
  let { r, g, b } = rgb;
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
  };
};

export const hsv2rgb = (hsv: WithOptional<HSV, 'h' | 's'>): RGB => {
  let { h, s, v } = hsv;
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
    return { r: v, g: v, b: v };
  }
  if (h >= 0 && h < 1) {
    return { r: c + m, g: x + m, b: m };
  }
  if (h >= 1 && h < 2) {
    return { r: x + m, g: c + m, b: m };
  }
  if (h >= 2 && h < 3) {
    return { r: m, g: c + m, b: x + m };
  }
  if (h >= 3 && h < 4) {
    return { r: m, g: x + m, b: c + m };
  }
  if (h >= 4 && h < 5) {
    return { r: x + m, g: m, b: c + m };
  }
  if (h >= 5 && h < 6) {
    return { r: c + m, g: m, b: x + m };
  }
  throw new Error(
    'Unreachable code - h is outside the range [0,6], which should not be possible.',
  );
};

export const hsva2hslString = (hsv: HSVA) => {
  const { h = 0, s, v, a } = hsv;
  const l = v * (1 - (s ?? 0) / 2);
  const sL = l === 0 || l === 1 ? 0 : (v - l) / Math.min(l, 1 - l);
  return `hsla(${h}, ${sL * 100}%, ${l * 100}%, ${a ?? 1})`;
};

export const isRgb = (color: RGB | HSV): color is RGB =>
  Object.keys(color).includes('r');
export const isHsv = (color: RGB | HSV): color is HSV =>
  Object.keys(color).includes('v');

type BothSpaces = RGBA & HSVA;

export const AsBothSpaces = (color: RGBA | HSVA): BothSpaces =>
  isRgb(color)
    ? { ...color, ...rgb2hsv(color) }
    : { ...color, ...hsv2rgb(color) };

export const colorToString = (color: RGBA | HSVA) => {
  const { a = 1 } = color;
  if (isRgb(color)) {
    const { r, g, b } = color;
    return `rgba(${r}, ${g}, ${b}, ${a})`;
  } else {
    return hsva2hslString(color);
  }
};

export const colorsAreEqual = (a: RGBA | HSVA, b: RGBA | HSVA) => {
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
