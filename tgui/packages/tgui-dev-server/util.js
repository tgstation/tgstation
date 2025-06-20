/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import path from 'node:path';

import { Glob } from 'bun';

export const resolvePath = path.resolve;

/**
 * Combines path.resolve with glob patterns.
 *
 * @param {string} directory - The directory to resolve the glob pattern against.
 * @param {string} [pattern='*'] - The glob pattern to match files against. Defaults to '*', which matches all files in the directory.
 * @returns {Promise<string[]>} - A promise that resolves to an array of matched file paths.
 */
export async function resolveGlob(directory, pattern = '*') {
  // If no pattern is supplied, just return the directory if it exists
  if (pattern === '*') {
    try {
      const stat = await Bun.file(directory).stat();
      if (stat?.isDirectory()) {
        return [directory];
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  // Otherwise, use glob logic
  const glob = new Glob(pattern);
  /** @type string[] */
  const results = [];

  for await (const match of glob.scan({ onlyFiles: false, cwd: directory })) {
    results.push(path.resolve(directory, match));
  }

  return results;
}
