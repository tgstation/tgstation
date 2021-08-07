/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'common/logging.js';
import fs from 'fs';
import { createRequire } from 'module';
import { dirname } from 'path';
import { loadSourceMaps, setupLink } from './link/server.js';
import { reloadByondCache } from './reloader.js';
import { resolveGlob } from './util.js';

const logger = createLogger('webpack');

/**
 * @param {any} config
 * @return {WebpackCompiler}
 */
export const createCompiler = async options => {
  const compiler = new WebpackCompiler();
  await compiler.setup(options);
  return compiler;
};

class WebpackCompiler {
  async setup(options) {
    // Create a require context that is relative to project root
    // and retrieve all necessary dependencies.
    const requireFromRoot = createRequire(dirname(import.meta.url) + '/../..');
    const webpack = await requireFromRoot('webpack');
    const createConfig = await requireFromRoot('./webpack.config.js');
    const config = createConfig({}, options);
    // Inject the HMR plugin into the config if we're using it
    if (options.hot) {
      config.plugins.push(new webpack.HotModuleReplacementPlugin());
    }
    this.webpack = webpack;
    this.config = config;
    this.bundleDir = config.output.path;
  }

  async watch() {
    logger.log('setting up');
    // Setup link
    const link = setupLink();
    // Instantiate the compiler
    const compiler = this.webpack.webpack(this.config);
    // Clear garbage before compiling
    compiler.hooks.watchRun.tapPromise('tgui-dev-server', async () => {
      const files = await resolveGlob(this.bundleDir, './*.hot-update.*');
      logger.log(`clearing garbage (${files.length} files)`);
      for (let file of files) {
        fs.unlinkSync(file);
      }
      logger.log('compiling');
    });
    // Start reloading when it's finished
    compiler.hooks.done.tap('tgui-dev-server', async stats => {
      // Load source maps
      await loadSourceMaps(this.bundleDir);
      // Reload cache
      await reloadByondCache(this.bundleDir);
      // Notify all clients that update has happened
      link.broadcastMessage({
        type: 'hotUpdate',
      });
    });
    // Start watching
    logger.log('watching for changes');
    compiler.watch({}, (err, stats) => {
      if (err) {
        logger.error('compilation error', err);
        return;
      }
      stats
        .toString(this.config.devServer.stats)
        .split('\n')
        .forEach(line => logger.log(line));
    });
  }
}
