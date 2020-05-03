// Inferno needs Int32Array, and it is not covered by core-js.
if (!window.Int32Array) {
  window.Int32Array = Array;
}
