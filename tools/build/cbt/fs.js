/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const fs = require('fs');
const glob = require('./glob');

class File {
  constructor(path) {
    this.path = path;
  }

  get stat() {
    if (this._stat === undefined) {
      this._stat = stat(this.path);
    }
    return this._stat;
  }

  exists() {
    return this.stat !== null;
  }

  get mtime() {
    return this.stat && this.stat.mtime;
  }

  touch() {
    const time = new Date();
    try {
      fs.utimesSync(this.path, time, time);
    }
    catch (err) {
      fs.closeSync(fs.openSync(this.path, 'w'));
    }
  }
}

class Glob {
  constructor(path) {
    this.path = path;
  }

  toFiles() {
    const paths = glob.sync(this.path, {
      strict: false,
      silent: true,
    });
    return paths
      .map(path => new File(path))
      .filter(file => file.exists());
  }
}

/**
 * If true, source is newer than target.
 * @param {File[]} sources
 * @param {File[]} targets
 */
const compareFiles = (sources, targets) => {
  let bestSource = null;
  let bestTarget = null;
  for (const file of sources) {
    if (!bestSource || file.mtime > bestSource.mtime) {
      bestSource = file;
    }
  }
  for (const file of targets) {
    if (!file.exists()) {
      return `target '${file.path}' is missing`;
    }
    if (!bestTarget || file.mtime < bestTarget.mtime) {
      bestTarget = file;
    }
  }
  // Doesn't need rebuild if there is no source, but target exists.
  if (!bestSource) {
    if (bestTarget) {
      return false;
    }
    return 'no known sources or targets';
  }
  // Always needs a rebuild if no targets were specified (e.g. due to GLOB).
  if (!bestTarget) {
    return 'no targets were specified';
  }
  // Needs rebuild if source is newer than target
  if (bestSource.mtime > bestTarget.mtime) {
    return `source '${bestSource.path}' is newer than target '${bestTarget.path}'`;
  }
  return false;
};

/**
 * Returns file stats for the provided path, or null if file is
 * not accessible.
 */
const stat = path => {
  try {
    return fs.statSync(path);
  }
  catch {
    return null;
  }
};

/**
 * Resolves a glob pattern and returns files that are safe
 * to call `stat` on.
 */
const resolveGlob = globPath => {
  const unsafePaths = glob.sync(globPath, {
    strict: false,
    silent: true,
  });
  const safePaths = [];
  for (let path of unsafePaths) {
    try {
      fs.statSync(path);
      safePaths.push(path);
    }
    catch {}
  }
  return safePaths;
};

module.exports = {
  File,
  Glob,
  compareFiles,
  stat,
  resolveGlob,
  compareFiles,
};
