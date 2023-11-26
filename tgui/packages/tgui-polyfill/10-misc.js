/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/* eslint-disable */
// prettier-ignore
(function () {
  'use strict';

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
