/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { loadCSS as fgLoadCSS } from 'fg-loadcss';
import { createLogger } from './logging';

const logger = createLogger('assets');

const loadedAssets = {
  styles: [],
};

export const loadCSS = filename => {
  if (loadedAssets.styles.includes(filename)) {
    return;
  }
  loadedAssets.styles.push(filename);
  logger.log(`loading stylesheet '${filename}'`);
  fgLoadCSS(filename);
};
