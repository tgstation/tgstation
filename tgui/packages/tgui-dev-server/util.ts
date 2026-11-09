/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import path from 'node:path';

import { Glob } from 'bun';

export const resolvePath = path.resolve;

/** Combines path.resolve with glob patterns. */
export async function resolveGlob(
  directory: string,
  pattern = '*',
): Promise<string[]> {
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
  const results: string[] = [];

  for await (const match of glob.scan({ onlyFiles: false, cwd: directory })) {
    results.push(path.resolve(directory, match));
  }

  return results;
}
