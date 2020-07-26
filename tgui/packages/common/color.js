/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const EPSILON = 0.0001;

export class Color {
  constructor(r = 0, g = 0, b = 0, a = 1) {
    Object.assign(this, { r, g, b, a });
  }

  toString() {
    return `rgba(${this.r | 0}, ${this.g | 0}, ${this.b | 0}, ${this.a | 0})`;
  }
}

/**
 * Creates a color from the CSS hex color notation.
 */
Color.fromHex = hex => (
  new Color(
    parseInt(hex.substr(1, 2), 16),
    parseInt(hex.substr(3, 2), 16),
    parseInt(hex.substr(5, 2), 16))
);

/**
 * Linear interpolation of two colors.
 */
Color.lerp = (c1, c2, n) => (
  new Color(
    (c2.r - c1.r) * n + c1.r,
    (c2.g - c1.g) * n + c1.g,
    (c2.b - c1.b) * n + c1.b,
    (c2.a - c1.a) * n + c1.a)
);

/**
 * Loops up the color in the provided list of colors
 * with linear interpolation.
 */
Color.lookup = (value, colors = []) => {
  const len = colors.length;
  if (len < 2) {
    throw new Error('Needs at least two colors!');
  }
  const scaled = value * (len - 1);
  if (value < EPSILON) {
    return colors[0];
  }
  if (value >= 1 - EPSILON) {
    return colors[len - 1];
  }
  const ratio = scaled % 1;
  const index = scaled | 0;
  return Color.lerp(colors[index], colors[index + 1], ratio);
};
