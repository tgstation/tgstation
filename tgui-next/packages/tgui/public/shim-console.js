/**
 * Adds a console object stub for IE8.
 */

/* eslint-disable */
(function () {

// Ignore user agents with console.
if (window.console) {
  return;
}

var noop = function () {};

// Start shimming
window.console = {};

console.debug = noop;
console.error = noop;
console.info = noop;
console.log = noop;
console.trace = noop;
console.warn = noop;

console.assert = noop;
console.count = noop;
console.dir = noop;
console.dirxml = noop;
console.exception = noop;
console.group = noop;
console.groupCollapsed = noop;
console.groupEnd = noop;
console.table = noop;
console.clear = noop;
console.count = noop;
console.profile = noop;
console.profileEnd = noop;
console.timeStamp = noop;

})();
