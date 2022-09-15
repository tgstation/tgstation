/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from 'fs';
import path from 'path';
import { require } from './require.js';

const globPkg = require('glob');

export const resolvePath = path.resolve;

/**
 * Combines path.resolve with glob patterns.
 */
export const resolveGlob = (...sections) => {
  const unsafePaths = globPkg.sync(path.resolve(...sections), {
    strict: false,
    silent: true,
  });
  const safePaths = [];
  for (let path of unsafePaths) {
    try {
      fs.statSync(path);
      safePaths.push(path);
    } catch {}
  }
  return safePaths;
};
