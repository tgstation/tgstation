const buildQueryString = obj => Object.keys(obj)
  .map(key => encodeURIComponent(key)
    + '=' + encodeURIComponent(obj[key]))
  .join('&');

/**
 * Helper to generate a BYOND href given 'params' as an object
 * (with an optional 'url' for eg winset).
 */
export const href = (url, params = {}) => {
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

// Helper to make a BYOND ui_act() call on the UI 'src' given an 'action'
// and optional 'params'.
export const act = (src, action, params = {}) =>
  callByond('', { src, action, ...params });

export const runCommand = command => callByond('winset', { command });

/**
 * A simple debug print.
 *
 * TODO: Find a better way to debug print.
 * Right now we just print into the game chat.
 */
export const debugPrint = (...args) => {
  const str = args
    .map(arg => {
      if (typeof arg === 'string') {
        return arg;
      }
      return JSON.stringify(arg);
    })
    .join(' ');
  return runCommand('Me [debugPrint] ' + str);
};

export const winget = async (win, key) => {
  const obj = await callByondAsync('winget', {
    id: win,
    property: key,
  });
  return obj[key];
};

// Helper to make a BYOND winset() call on 'window', setting 'key' to 'value'
export const winset = (win, key, value) => callByond('winset', {
  [`${win}.${key}`]: value,
});
