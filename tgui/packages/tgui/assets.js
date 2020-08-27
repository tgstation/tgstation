/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { loadCSS as fgLoadCss } from 'fg-loadcss';
import { createLogger } from './logging';

const logger = createLogger('assets');

const EXCLUDED_PATTERNS = [/v4shim/i];
const RETRY_ATTEMPTS = 5;
const RETRY_INTERVAL = 3000;

const loadedStyleSheetByUrl = {};
const loadedMappings = {};

export const loadStyleSheet = (url, attempt = 1) => {
  if (loadedStyleSheetByUrl[url]) {
    return;
  }
  loadedStyleSheetByUrl[url] = true;
  logger.log(`loading stylesheet '${url}'`);
  /** @type {HTMLLinkElement} */
  let node = fgLoadCss(url);
  node.addEventListener('load', () => {
    if (!isStyleSheetReallyLoaded(node, url)) {
      node.parentNode.removeChild(node);
      node = null;
      loadedStyleSheetByUrl[url] = null;
      if (attempt >= RETRY_ATTEMPTS) {
        logger.error(`Error: Failed to load the stylesheet `
          + `'${url}' after ${RETRY_ATTEMPTS} attempts.\nIt was either `
          + `not found, or you're trying to load an empty stylesheet `
          + `that has no CSS rules in it.`);
        return;
      }
      setTimeout(() => loadStyleSheet(url, attempt + 1), RETRY_INTERVAL);
      return;
    }
  });
};

/**
 * Checks whether the stylesheet was registered in the DOM
 * and is not empty.
 */
const isStyleSheetReallyLoaded = (node, url) => {
  // Method #1 (works on IE10+)
  const styleSheet = node.sheet;
  if (styleSheet) {
    return styleSheet.rules.length > 0;
  }
  // Method #2
  const styleSheets = document.styleSheets;
  const len = styleSheets.length;
  for (let i = 0; i < len; i++) {
    const styleSheet = styleSheets[i];
    if (styleSheet.href.includes(url)) {
      return styleSheet.rules.length > 0;
    }
  }
  // All methods failed
  logger.warn(`Warning: stylesheet '${url}' was not found in the DOM`);
  return false;
};

export const resolveAsset = name => (
  loadedMappings[name] || name
);

export const assetMiddleware = store => next => action => {
  const { type, payload } = action;
  if (type === 'asset/stylesheet') {
    loadStyleSheet(payload);
    return;
  }
  if (type === 'asset/mappings') {
    for (let name of Object.keys(payload)) {
      // Skip anything that matches excluded patterns
      if (EXCLUDED_PATTERNS.some(regex => regex.test(name))) {
        continue;
      }
      const url = payload[name];
      const ext = name.split('.').pop();
      loadedMappings[name] = url;
      if (ext === 'css') {
        loadStyleSheet(url);
      }
    }
    return;
  }
  next(action);
};
