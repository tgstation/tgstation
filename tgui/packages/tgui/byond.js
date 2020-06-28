/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Reference a global Byond object
const { Byond } = window;

/**
 * Version of Trident engine used in Internet Explorer.
 * An integer number or `null` if this is not a trident engine.
 *
 * - IE 8 - Trident 4.0
 * - IE 11 - Trident 7.0
 */
const tridentVersion = (() => {
  const groups = navigator.userAgent.match(/Trident\/(\d+).+?;/i);
  if (!groups) {
    return null;
  }
  const majorVersion = groups[1];
  if (!majorVersion) {
    return null;
  }
  return parseInt(majorVersion, 10);
})();

/**
 * True if browser is an Internet Explorer 8 or lower.
 *
 * (Actually, no, it also includes IE9 and IE10).
 */
export const IS_IE8 = tridentVersion !== null
  && tridentVersion <= 6;

/**
 * Makes a BYOND call.
 *
 * If path is empty, this will trigger a Topic call.
 * You can reference a specific object by setting the "src" parameter.
 *
 * See: https://secure.byond.com/docs/ref/skinparams.html
 */
export const callByond = (path, params = {}) => {
  Byond.call(path, params);
};

/**
 * A high-level abstraction of BYOND calls. Makes a BYOND call and returns
 * a promise, which (if endpoint has a callback parameter) resolves
 * with the return value of that call.
 */
export const callByondAsync = (path, params = {}) => {
  // Create a callback array if it doesn't exist yet
  window.__callbacks__ = window.__callbacks__ || [];
  // Create a Promise and push its resolve function into callback array
  const callbackIndex = window.__callbacks__.length;
  const promise = new Promise(resolve => {
    // TODO: Fix a potential memory leak
    window.__callbacks__.push(resolve);
  });
  // Call BYOND client
  Byond.call(path, {
    ...params,
    callback: `__callbacks__[${callbackIndex}]`,
  });
  return promise;
};

/**
 * Runs a BYOND skin command
 *
 * See: https://secure.byond.com/docs/ref/skinparams.html
 */
export const runCommand = command => callByond('winset', { command });

/**
 * Calls 'winget' on a BYOND skin element, retrieving value by the 'key'.
 */
export const winget = async (id, key) => {
  const obj = await callByondAsync('winget', {
    id,
    property: key,
  });
  return obj[key];
};

/**
 * Calls 'winset' on a BYOND skin element, setting 'key' to 'value'.
 */
export const winset = (id, key, value) => callByond('winset', {
  [`${id}.${key}`]: value,
});
