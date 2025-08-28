/**
 * N-dimensional vector manipulation functions.
 *
 * Vectors are plain number arrays, i.e. [x, y, z].
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { zip } from 'es-toolkit';
import { map, reduce } from 'es-toolkit/compat';

const ADD = (a: number, b: number): number => a + b;
const SUB = (a: number, b: number): number => a - b;
const MUL = (a: number, b: number): number => a * b;
const DIV = (a: number, b: number): number => a / b;

export type Vector = number[];

// It's really not ideal to bypass the type system and use `as Vector`
// however, there isn't a more eloquent way to type these

export const vecAdd = (...vecs: Vector[]): Vector => {
  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, ADD)) as Vector;
};

export const vecSubtract = (...vecs: Vector[]): Vector => {
  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, SUB)) as Vector;
};

export const vecMultiply = (...vecs: Vector[]): Vector => {
  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, MUL)) as Vector;
};

export const vecDivide = (...vecs: Vector[]): Vector => {
  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, DIV)) as Vector;
};

export const vecScale = (vec: Vector, n: number): Vector => {
  return map(vec, (x) => x * n);
};

export const vecInverse = (vec: Vector): Vector => {
  return map(vec, (x) => -x);
};

export const vecLength = (vec: Vector): number => {
  return Math.sqrt(reduce(vecMultiply(vec, vec), ADD) as number);
};

export const vecNormalize = (vec: Vector): Vector => {
  const length = vecLength(vec);
  return map(vec, (c) => c / length);
};
