/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/* eslint-disable */
(function () {
  'use strict';

  // ie11 polyfills
  !(function () {
    // append
    function t() {
      var e = Array.prototype.slice.call(arguments),
        n = document.createDocumentFragment();
      e.forEach(function (e) {
        var t = e instanceof Node;
        n.appendChild(t ? e : document.createTextNode(String(e)));
      }),
        this.appendChild(n);
    }
    // remove
    function n() {
      this.parentNode && this.parentNode.removeChild(this);
    }

    // add to prototype
    [Element.prototype, Document.prototype, DocumentFragment.prototype].forEach(
      function (e) {
        e.hasOwnProperty('append') ||
          Object.defineProperty(e, 'append', {
            configurable: !0,
            enumerable: !0,
            writable: !0,
            value: t,
          });
        e.hasOwnProperty('remove') ||
          Object.defineProperty(e, 'remove', {
            configurable: !0,
            enumerable: !0,
            writable: !0,
            value: n,
          });
      }
    );
  })();
})();
