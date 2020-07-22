/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { loadCSS as fgLoadCSS } from 'fg-loadcss';
import { createLogger } from './logging';

const logger = createLogger('assets');

const EXCLUDED_PATTERNS = [
  /v4shim/i,
];

const loadedStyles = [];
const loadedMappings = {};

export const loadCSS = url => {
  if (loadedStyles.includes(url)) {
    return;
  }
  loadedStyles.push(url);
  logger.log(`loading stylesheet '${url}'`);
  fgLoadCSS(url);
};

export const resolveAsset = name => (
  loadedMappings[name] || name
);

export const assetMiddleware = store => next => action => {
  const { type, payload } = action;
  if (type === 'asset/stylesheet') {
    loadCSS(payload);
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
        loadCSS(url);
      }
    }
    return;
  }
  next(action);
};
