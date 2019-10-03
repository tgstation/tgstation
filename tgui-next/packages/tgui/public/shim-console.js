/**
 * Shims the console in embedded IE8 window.
 *
 * You can subscribe using console.__subscribe__(fn) to handle
 * incoming log messages, otherwise they will be simply lost.
 */

/* eslint-disable */
(function () {

// Ignore user agents with console.
if (window.console) {
  return;
}

var noop = function () {};

var handleLogs = function () {
  for (var i = 0; i < subscribers.length; i++) {
    subscribers[i].apply(null, arguments);
  }
};

var subscribers = [];

// Start shimming
window.console = {};

console.__subscribe__ = function (fn) {
  subscribers.push(fn);
};

console.debug = handleLogs;
console.error = handleLogs;
console.info = handleLogs;
console.log = handleLogs;
console.trace = handleLogs;
console.warn = handleLogs;

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
