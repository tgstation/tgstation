/**
 * N-dimensional vector manipulation functions.
 *
 * Vectors are plain number arrays, i.e. [x, y, z].
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { zip } from './collections';

const ADD = (a, b) => a + b;
const SUB = (a, b) => a - b;
const MUL = (a, b) => a * b;
const DIV = (a, b) => a / b;

export type Vector = number[];

export const vecAdd = (...vecs: Vector[]) => {
  return zip(...vecs).map((x) => x.reduce(ADD));
};

export const vecSubtract = (...vecs: Vector[]) => {
  return zip(...vecs).map((x) => x.reduce(SUB));
};

export const vecMultiply = (...vecs: Vector[]) => {
  return zip(...vecs).map((x) => x.reduce(MUL));
};

export const vecDivide = (...vecs: Vector[]) => {
  return zip(...vecs).map((x) => x.reduce(DIV));
};

export const vecScale = (vec: Vector, n: number) => {
  return vec.map((x) => x * n);
};

export const vecInverse = (vec: Vector) => {
  return vec.map((x) => -x);
};

export const vecLength = (vec: Vector) => {
  return Math.sqrt(vecMultiply(vec, vec).reduce(ADD));
};

export const vecNormalize = (vec: Vector) => {
  const length = vecLength(vec);
  return vec.map((c) => c / length);
};
