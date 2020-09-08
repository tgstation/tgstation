/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Inferno needs Int32Array, and it is not covered by core-js.
if (!window.Int32Array) {
  window.Int32Array = Array;
}
