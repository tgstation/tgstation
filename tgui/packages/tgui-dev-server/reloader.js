/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'common/logging.js';
import fs from 'fs';
import os from 'os';
import { basename } from 'path';
import { promisify } from 'util';
import { resolveGlob, resolvePath } from './util.js';
import { regQuery } from './winreg.js';

const logger = createLogger('reloader');

const HOME = os.homedir();
const SEARCH_LOCATIONS = [
  // Custom location
  process.env.BYOND_CACHE,
  // Windows
  `${HOME}/*/BYOND/cache`,
  // Wine
  `${HOME}/.wine/drive_c/users/*/*/BYOND/cache`,
  // Lutris
  `${HOME}/Games/byond/drive_c/users/*/*/BYOND/cache`,
  // WSL
  `/mnt/c/Users/*/*/BYOND/cache`,
];

let cacheRoot;

export const findCacheRoot = async () => {
  if (cacheRoot) {
    return cacheRoot;
  }
  logger.log('looking for byond cache');
  // Find BYOND cache folders
  for (let pattern of SEARCH_LOCATIONS) {
    if (!pattern) {
      continue;
    }
    const paths = await resolveGlob(pattern);
    if (paths.length > 0) {
      cacheRoot = paths[0];
      logger.log(`found cache at '${cacheRoot}'`);
      return cacheRoot;
    }
  }
  // Query the Windows Registry
  if (process.platform === 'win32') {
    logger.log('querying windows registry');
    let userpath = await regQuery(
      'HKCU\\Software\\Dantom\\BYOND',
      'userpath');
    if (userpath) {
      cacheRoot = userpath
        .replace(/\\$/, '')
        .replace(/\\/g, '/')
        + '/cache';
      logger.log(`found cache at '${cacheRoot}'`);
      return cacheRoot;
    }
  }
  logger.log('found no cache directories');
};

export const reloadByondCache = async bundleDir => {
  const cacheRoot = await findCacheRoot();
  if (!cacheRoot) {
    return;
  }
  // Find tmp folders in cache
  const cacheDirs = await resolveGlob(cacheRoot, './tmp*');
  if (cacheDirs.length === 0) {
    logger.log('found no tmp folder in cache');
    return;
  }
  const assets = await resolveGlob(bundleDir, './*.+(bundle|hot-update).*');
  for (let cacheDir of cacheDirs) {
    // Clear garbage
    const garbage = await resolveGlob(cacheDir, './*.+(bundle|hot-update).*');
    for (let file of garbage) {
      await promisify(fs.unlink)(file);
    }
    // Copy assets
    for (let asset of assets) {
      const destination = resolvePath(cacheDir, basename(asset));
      await promisify(fs.copyFile)(asset, destination);
    }
    logger.log(`copied ${assets.length} files to '${cacheDir}'`);
  }
};
