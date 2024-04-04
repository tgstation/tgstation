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

const ADD = (a: number, b: number): number => a + b;
const SUB = (a: number, b: number): number => a - b;
const MUL = (a: number, b: number): number => a * b;
const DIV = (a: number, b: number): number => a / b;

export type Vector = number[];

export const vecAdd = (...vecs: Vector[]): Vector => {
  return zip(...vecs).map((x) => x.reduce(ADD));
};

export const vecSubtract = (...vecs: Vector[]): Vector => {
  return zip(...vecs).map((x) => x.reduce(SUB));
};

export const vecMultiply = (...vecs: Vector[]): Vector => {
  return zip(...vecs).map((x) => x.reduce(MUL));
};

export const vecDivide = (...vecs: Vector[]): Vector => {
  return zip(...vecs).map((x) => x.reduce(DIV));
};

export const vecScale = (vec: Vector, n: number): Vector => {
  return vec.map((x) => x * n);
};

export const vecInverse = (vec: Vector): Vector => {
  return vec.map((x) => -x);
};

export const vecLength = (vec: Vector): number => {
  return Math.sqrt(vecMultiply(vec, vec).reduce(ADD));
};

export const vecNormalize = (vec: Vector): Vector => {
  const length = vecLength(vec);
  return vec.map((c) => c / length);
};
