import { createLogger } from 'common/logging.js';
import fs from 'fs';
import glob from 'glob';
import { createRequire } from 'module';
import os from 'os';
import path from 'path';
import util from 'util';
import webpack from 'webpack';
import { broadcastMessage, setupLink } from './link/server.js';

const WEBPACK_HMR_ENABLED = process.platform === 'win32'
  || process.argv.includes('--hot');

const setupServer = async () => {
  const link = setupLink();
  await setupWebpack(link);
};

const getWebpackConfig = async () => {
  const logger = createLogger('webpack');
  const require = createRequire(import.meta.url);
  const createConfig = await require('../tgui/webpack.config.js');
  const config = createConfig({}, {
    mode: 'development',
    // Enable hot module reloading only on Windows.
    hot: WEBPACK_HMR_ENABLED,
  });
  if (!WEBPACK_HMR_ENABLED) {
    logger.log('hot module reloading is disabled');
  }
  return config;
};

const setupWebpack = async link => {
  const logger = createLogger('webpack');
  logger.log('setting up');
  const config = await getWebpackConfig();
  const bundleDir = config.output.path;
  // Instantiate the compiler
  const compiler = webpack(config);
  // Clear garbage before compiling
  compiler.hooks.watchRun.tapPromise('tgui-dev-server', async () => {
    const files = await resolvePath(bundleDir, './*.hot-update.*');
    logger.log(`clearing garbage (${files.length} files)`);
    for (let file of files) {
      await util.promisify(fs.unlink)(file);
    }
    logger.log('compiling');
  });
  // Start reloading when it's finished
  compiler.hooks.done.tap('tgui-dev-server', async stats => {
    await reloadByondCache(bundleDir);
    // Notify all clients that update has happened
    if (WEBPACK_HMR_ENABLED) {
      broadcastMessage(link, {
        type: 'hotUpdate',
      });
    }
  });
  // Start watching
  logger.log('watching for changes');
  compiler.watch({}, (err, stats) => {
    if (err) {
      logger.error('compilation error', err);
      return;
    }
    logger.log(stats.toString(config.devServer.stats));
  });
};

/**
 * Combines path.resolve with glob patterns.
 */
const resolvePath = (...sections) => {
  return util.promisify(glob)(path.resolve(...sections));
};

const CACHE_PATTERN = './BYOND/cache/tmp*';

const reloadByondCache = async bundleDir => {
  const logger = createLogger('reloader');
  // Find BYOND cache folders
  const cacheDirs = [
    // Windows 10
    ...(await resolvePath(os.homedir(), '*', CACHE_PATTERN)),
    // Standard Wine setup
    ...(await resolvePath(os.homedir(),
      '.wine/drive_c/users/*/*',
      CACHE_PATTERN)),
    // Standard Lutris setup
    ...(await resolvePath(os.homedir(),
      'Games/byond/drive_c/users/*/*',
      CACHE_PATTERN)),
  ];
  if (cacheDirs.length === 0) {
    logger.log('found no cache directories');
    return;
  }
  // Clear garbage
  for (let cacheDir of cacheDirs) {
    const garbage = await resolvePath(cacheDir, './*.+(bundle|hot-update).*');
    for (let file of garbage) {
      await util.promisify(fs.unlink)(file);
    }
  }
  // Copy assets
  const assets = await resolvePath(bundleDir, './*.+(bundle|hot-update).*');
  for (let cacheDir of cacheDirs) {
    for (let asset of assets) {
      const destination = path.resolve(cacheDir, path.basename(asset));
      await util.promisify(fs.copyFile)(asset, destination);
    }
    logger.log(`copied ${assets.length} files to '${cacheDir}'`);
  }
};

setupServer();
