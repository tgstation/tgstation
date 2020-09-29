/**
 * N-dimensional vector manipulation functions.
 *
 * Vectors are plain number arrays, i.e. [x, y, z].
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { map, reduce, zipWith } from './collections';

const ADD = (a, b) => a + b;
const SUB = (a, b) => a - b;
const MUL = (a, b) => a * b;
const DIV = (a, b) => a / b;

export const vecAdd = (...vecs) => {
  return reduce((a, b) => zipWith(ADD)(a, b))(vecs);
};

export const vecSubtract = (...vecs) => {
  return reduce((a, b) => zipWith(SUB)(a, b))(vecs);
};

export const vecMultiply = (...vecs) => {
  return reduce((a, b) => zipWith(MUL)(a, b))(vecs);
};

export const vecDivide = (...vecs) => {
  return reduce((a, b) => zipWith(DIV)(a, b))(vecs);
};

export const vecScale = (vec, n) => {
  return map(x => x * n)(vec);
};

export const vecInverse = vec => {
  return map(x => -x)(vec);
};

export const vecLength = vec => {
  return Math.sqrt(reduce(ADD)(zipWith(MUL)(vec, vec)));
};

export const vecNormalize = vec => {
  return vecDivide(vec, vecLength(vec));
};
