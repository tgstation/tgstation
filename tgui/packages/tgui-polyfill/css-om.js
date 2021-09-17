/**
 * CSS Object Model patches
 *
 * Adapted from: https://github.com/shawnbot/aight
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/* eslint-disable */
(function(Proto) {
  'use strict';

  if (typeof Proto.setAttribute !== 'undefined') {
    function toAttr(prop) {
      return prop.replace(/-[a-z]/g, function (bit) {
        return bit[1].toUpperCase();
      });
    }

    Proto.setProperty = function (prop, value) {
      var attr = toAttr(prop);
      if (!value) {
        return this.removeAttribute(attr);
      }
      var str = String(value);
      return this.setAttribute(attr, str);
    };

    Proto.getPropertyValue = function (prop) {
      var attr = toAttr(prop);
      return this.getAttribute(attr) || null;
    };

    Proto.removeProperty = function (prop) {
      var attr = toAttr(prop);
      var value = this.getAttribute(attr);
      this.removeAttribute(attr);
      return value;
    };
  }

})(CSSStyleDeclaration.prototype);
