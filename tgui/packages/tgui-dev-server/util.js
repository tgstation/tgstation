/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs, { globSync } from 'node:fs';
import path from 'node:path';

export const resolvePath = path.resolve;

/** Combines path.resolve with glob patterns. */
export function resolveGlob(...sections) {
  /** @type {string[]} */
  const unsafePaths = globSync(path.resolve(...sections));

  /** @type {string[]} */
  const safePaths = [];

  for (let path of unsafePaths) {
    try {
      fs.statSync(path);
      safePaths.push(path);
    } catch {}
  }

  return safePaths;
}
