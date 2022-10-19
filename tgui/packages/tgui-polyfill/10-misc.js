/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/* eslint-disable */
// prettier-ignore
(function () {
  'use strict';

  // Necessary polyfill to make Webpack code splitting work on IE8
  if (!Function.prototype.bind) (function () {
    var slice = Array.prototype.slice;
    Function.prototype.bind = function () {
      var thatFunc = this, thatArg = arguments[0];
      var args = slice.call(arguments, 1);
      if (typeof thatFunc !== 'function') {
        // closest thing possible to the ECMAScript 5
        // internal IsCallable function
        throw new TypeError('Function.prototype.bind - ' +
          'what is trying to be bound is not callable');
      }
      return function () {
        var funcArgs = args.concat(slice.call(arguments))
        return thatFunc.apply(thatArg, funcArgs);
      };
    };
  })();

  if (!Array.prototype['forEach']) {
    Array.prototype.forEach = function (callback, thisArg) {
      if (this == null) {
        throw new TypeError('Array.prototype.forEach called on null or undefined');
      }
      var T, k;
      var O = Object(this);
      var len = O.length >>> 0;
      if (typeof callback !== "function") {
        throw new TypeError(callback + ' is not a function');
      }
      if (arguments.length > 1) {
        T = thisArg;
      }
      k = 0;
      while (k < len) {
        var kValue;
        if (k in O) {
          kValue = O[k];
          callback.call(T, kValue, k, O);
        }
        k++;
      }
    };
  }

  // Inferno needs Int32Array, and it is not covered by core-js.
  if (!window.Int32Array) {
    window.Int32Array = Array;
  }

})();
