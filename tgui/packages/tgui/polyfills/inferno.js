/**
 * @file
 * @copyright Aleksej Komarov 2020
 * @license MIT
 */

// Inferno needs Int32Array, and it is not covered by core-js.
if (!window.Int32Array) {
  window.Int32Array = Array;
}
