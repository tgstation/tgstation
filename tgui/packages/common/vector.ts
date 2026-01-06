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

export type Vector = number[];

export function vecAdd(...vecs: Vector[]): Vector {
  return zip(...vecs).map((xs) => xs.reduce((a, b) => a + b));
}

export function vecSubtract(...vecs: Vector[]): Vector {
  return zip(...vecs).map((xs) => xs.reduce((a, b) => a - b));
}

export function vecMultiply(...vecs: Vector[]): Vector {
  return zip(...vecs).map((xs) => xs.reduce((a, b) => a * b));
}

export function vecDivide(...vecs: Vector[]): Vector {
  return zip(...vecs).map((xs) => xs.reduce((a, b) => a / b));
}

export function vecScale(vec: Vector, n: number): Vector {
  return vec.map((x) => x * n);
}

export function vecInverse(vec: Vector): Vector {
  return vec.map((x) => -x);
}

export function vecLength(vec: Vector): number {
  return Math.sqrt(vec.reduce((sum, x) => sum + x * x, 0));
}

export function vecNormalize(vec: Vector): Vector {
  const length = vecLength(vec);
  return vec.map((c) => c / length);
}
