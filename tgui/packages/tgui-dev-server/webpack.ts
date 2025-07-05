import { createRequire } from 'node:module';

import rspack, { Configuration } from '@rspack/core';

import { config } from '../../rspack.config-dev';
import { loadSourceMaps } from './link/retrace';
import { broadcastMessage, setupLink } from './link/server';
import { createLogger } from './logging';
import { reloadByondCache } from './reloader';
import { resolveGlob } from './util';

type RsPack = typeof rspack;

const logger = createLogger('rspack');

export class RspackCompiler {
  rspack: RsPack;
  config: Configuration;
  bundleDir: string;

  async setup() {
    // Create a require context that is relative to project root
    // and retrieve all necessary dependencies.
    const requireFromRoot = createRequire(import.meta.dirname + '/../../..');
    const rspack: RsPack = await requireFromRoot('@rspack/core');

    this.rspack = rspack;
    this.config = config;
    this.bundleDir = config.output?.path || '';
  }

  async watch() {
    logger.log('setting up');
    // Setup link
    const link = setupLink();
    // Instantiate the compiler
    const compiler = this.rspack.rspack(this.config);

    // Clear garbage before compiling
    compiler.hooks.watchRun.tapPromise('tgui-dev-server', async () => {
      const files = await resolveGlob(this.bundleDir, '*.hot-update.*');
      for (const file of files) {
        await Bun.file(file).delete();
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
      broadcastMessage({
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
        ?.toString(this.config.stats)
        .split('\n')
        .forEach((line) => logger.log(line));
    });
  }
}
