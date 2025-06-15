/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from 'node:fs';
import { createRequire } from 'node:module';

import { loadSourceMaps, setupLink } from './link/server.js';
import { createLogger } from './logging.js';
import { reloadByondCache } from './reloader.js';
import { resolveGlob } from './util.js';

const logger = createLogger('rspack');

/**
 * @param {any} config
 * @return {RspackCompiler}
 */
export async function createCompiler(options) {
  const compiler = new RspackCompiler();
  await compiler.setup(options);

  return compiler;
}

class RspackCompiler {
  async setup(options) {
    // Create a require context that is relative to project root
    // and retrieve all necessary dependencies.
    const requireFromRoot = createRequire(import.meta.dirname + '/../../..');
    /** @type {typeof import('@rspack/core')} */
    const rspack = await requireFromRoot('@rspack/core');

    const createConfig = await requireFromRoot('./rspack.config.cjs');
    const createDevConfig = await requireFromRoot('./rspack.config-dev.cjs');

    const config = createConfig({}, options);
    const devConfig = createDevConfig({}, options);

    const mergedConfig = { ...config, ...devConfig };

    // Inject the HMR plugin into the config if we're using it
    if (options.hot) {
      mergedConfig.plugins.push(new rspack.HotModuleReplacementPlugin());
    }
    this.rspack = rspack;
    this.config = mergedConfig;
    this.bundleDir = config.output.path;
  }

  async watch() {
    logger.log('setting up');
    // Setup link
    const link = setupLink();
    // Instantiate the compiler
    const compiler = this.rspack.rspack(this.config);
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
    compiler.hooks.done.tap('tgui-dev-server', async (stats) => {
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
        ?.toString(this.config.devServer.stats)
        .split('\n')
        .forEach((line) => logger.log(line));
    });
  }
}
