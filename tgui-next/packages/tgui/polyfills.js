// This one is necessary for Inferno to do complex DOM patching on IE8.
// Not the fastest one or most spec compliant, but hey, it works!
if (!window.Int32Array) {
  window.Int32Array = Array;
}
