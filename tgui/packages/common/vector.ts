/**
 * N-dimensional vector manipulation functions.
 *
 * Vectors are plain number arrays, i.e. [x, y, z].
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { map, reduce, zip } from 'es-toolkit/compat';

const ADD = (a: number, b: number): number => a + b;
const SUB = (a: number, b: number): number => a - b;
const MUL = (a: number, b: number): number => a * b;
const DIV = (a: number, b: number): number => a / b;

export type Vector = number[];

export const vecAdd = (...vecs: Vector[]): Vector => {
  if (vecs.length === 0) {
    throw new Error('One or more vectors must be provided.');
  } else {
    const firstLength = vecs[0].length;
    for (let i = 1; i < vecs.length; i++) {
      if (vecs[i].length !== firstLength) {
        throw new Error('All vectors must have the same number of dimensions.');
      }
    }
  }

  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, ADD));
};

export const vecSubtract = (...vecs: Vector[]): Vector => {
  if (vecs.length === 0) {
    throw new Error('One or more vectors must be provided.');
  } else {
    const firstLength = vecs[0].length;
    for (let i = 1; i < vecs.length; i++) {
      if (vecs[i].length !== firstLength) {
        throw new Error('All vectors must have the same number of dimensions.');
      }
    }
  }

  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, SUB));
};

export const vecMultiply = (...vecs: Vector[]): Vector => {
  if (vecs.length === 0) {
    throw new Error('One or more vectors must be provided.');
  } else {
    const firstLength = vecs[0].length;
    for (let i = 1; i < vecs.length; i++) {
      if (vecs[i].length !== firstLength) {
        throw new Error('All vectors must have the same number of dimensions.');
      }
    }
  }

  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, MUL));
};

export const vecDivide = (...vecs: Vector[]): Vector => {
  if (vecs.length === 0) {
    throw new Error('One or more vectors must be provided.');
  } else {
    const firstLength = vecs[0].length;
    for (let i = 1; i < vecs.length; i++) {
      if (vecs[i].length !== firstLength) {
        throw new Error('All vectors must have the same number of dimensions.');
      }
    }
  }

  return map(zip<number>(...vecs) as Vector[], (x) => reduce(x, DIV));
};

export const vecScale = (vec: Vector, n: number): Vector => {
  return map(vec, (x) => x * n);
};

export const vecInverse = (vec: Vector): Vector => {
  return map(vec, (x) => -x);
};

export const vecLength = (vec: Vector): number => {
  return Math.sqrt(reduce(vecMultiply(vec, vec), ADD));
};

export const vecNormalize = (vec: Vector): Vector => {
  const length = vecLength(vec);
  return map(vec, (c) => c / length);
};
