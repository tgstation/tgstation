import { buildQueryString } from 'common/string';

/**
 * Version of Trident engine used in Internet Explorer.
 *
 * - IE 8 - Trident 4.0
 * - IE 11 - Trident 7.0
 *
 * @return An integer number or 'null' if this is not a trident engine.
 */
export const tridentVersion = (() => {
  const { userAgent } = navigator;
  const groups = userAgent.match(/Trident\/(\d+).+?;/i);
  const majorVersion = groups[1];
  if (!majorVersion) {
    return null;
  }
  return parseInt(majorVersion, 10);
})();

/**
 * Helper to generate a BYOND href given 'params' as an object
 * (with an optional 'url' for eg winset).
 */
const href = (url, params = {}) => {
  return 'byond://' + url + '?' + buildQueryString(params);
};

export const callByond = (url, params = {}) => {
  window.location.href = href(url, params);
};

/**
 * A high-level abstraction of BYJAX. Makes a call to BYOND and returns
 * a promise, which (if endpoint has a callback parameter) resolves
 * with the return value of that call.
 */
export const callByondAsync = (url, params = {}) => {
  // Create a callback array if it doesn't exist yet
  window.__callbacks__ = window.__callbacks__ || [];
  // Create a Promise and push its resolve function into callback array
  const callbackIndex = window.__callbacks__.length;
  const promise = new Promise(resolve => {
    // TODO: Fix a potential memory leak
    window.__callbacks__.push(resolve);
  });
  // Call BYOND client
  window.location.href = href(url, {
    ...params,
    callback: `__callbacks__[${callbackIndex}]`,
  });
  return promise;
};

/**
 * Literally types a command on the client.
 */
export const runCommand = command => callByond('winset', { command });

/**
 * Helper to make a BYOND ui_act() call on the UI 'src' given an 'action'
 * and optional 'params'.
 */
export const act = (src, action, params = {}) => {
  return callByond('', { src, action, ...params });
};

/**
 * Calls 'winget' on window, retrieving value by the 'key'.
 */
export const winget = async (win, key) => {
  const obj = await callByondAsync('winget', {
    id: win,
    property: key,
  });
  return obj[key];
};

/**
 * Calls 'winset' on window, setting 'key' to 'value'.
 */
export const winset = (win, key, value) => callByond('winset', {
  [`${win}.${key}`]: value,
});
