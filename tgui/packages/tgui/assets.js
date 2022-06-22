/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const EXCLUDED_PATTERNS = [/v4shim/i];
const loadedMappings = {};

export const resolveAsset = (name) => loadedMappings[name] || name;

export const assetMiddleware = (store) => (next) => (action) => {
  const { type, payload } = action;
  if (type === 'asset/stylesheet') {
    Byond.loadCss(payload);
    return;
  }
  if (type === 'asset/mappings') {
    for (let name of Object.keys(payload)) {
      // Skip anything that matches excluded patterns
      if (EXCLUDED_PATTERNS.some((regex) => regex.test(name))) {
        continue;
      }
      const url = payload[name];
      const ext = name.split('.').pop();
      loadedMappings[name] = url;
      if (ext === 'css') {
        Byond.loadCss(url);
      }
      if (ext === 'js') {
        Byond.loadJs(url);
      }
    }
    return;
  }
  next(action);
};
