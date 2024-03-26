/**
 * N-dimensional vector manipulation functions.
 *
 * Vectors are plain number arrays, i.e. [x, y, z].
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { zipWith } from './collections';

const ADD = (a, b) => a + b;
const SUB = (a, b) => a - b;
const MUL = (a, b) => a * b;
const DIV = (a, b) => a / b;

export const vecAdd = (...vecs) => {
  return vecs.reduce((a, b) => zipWith(ADD)(a, b));
};

export const vecSubtract = (...vecs) => {
  return vecs.reduce((a, b) => zipWith(SUB)(a, b));
};

export const vecMultiply = (...vecs) => {
  return vecs.reduce((a, b) => zipWith(MUL)(a, b));
};

export const vecDivide = (...vecs) => {
  return vecs.reduce((a, b) => zipWith(DIV)(a, b));
};

export const vecScale = (vec, n) => {
  return vec.map((x) => x * n);
};

export const vecInverse = (vec) => {
  return vec.map((x) => -x);
};

export const vecLength = (vec) => {
  return Math.sqrt(zipWith(MUL)(vec, vec).reduce(ADD));
};

export const vecNormalize = (vec) => {
  return vecDivide(vec, vecLength(vec));
};
