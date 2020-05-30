/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import glob from 'glob';
import { resolve as resolvePath } from 'path';
import fs from 'fs';
import { promisify } from 'util';

export { resolvePath };

/**
 * Combines path.resolve with glob patterns.
 */
export const resolveGlob = async (...sections) => {
  const unsafePaths = await promisify(glob)(
    resolvePath(...sections), {
      strict: false,
      silent: true,
    });
  const safePaths = [];
  for (let path of unsafePaths) {
    try {
      await promisify(fs.stat)(path);
      safePaths.push(path);
    }
    catch {}
  }
  return safePaths;
};
