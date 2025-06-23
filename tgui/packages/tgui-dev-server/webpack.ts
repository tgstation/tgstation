/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createRequire } from 'module';

import { loadSourceMaps } from './link/retrace';
import { broadcastMessage, setupLink } from './link/server';
import { createLogger } from './logging.js';
import { reloadByondCache } from './reloader.js';
import { resolveGlob } from './util';

const logger = createLogger('webpack');

export async function createCompiler(
  options: Record<string, any>,
): Promise<WebpackCompiler> {
  const compiler = new WebpackCompiler();
  await compiler.setup(options);

  return compiler;
}

type WebpackImport = typeof import('webpack');

class WebpackCompiler {
  public webpack: WebpackImport;
  public config: Record<string, any>;
  public bundleDir: string;

  async setup(options: Record<string, any>): Promise<void> {
    // Create a require context that is relative to project root
    // and retrieve all necessary dependencies.
    const requireFromRoot = createRequire(import.meta.dirname + '/../../..');
    const webpack: WebpackImport = await requireFromRoot('webpack');

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

  async watch(): Promise<void> {
    logger.log('setting up');
    // Setup link
    const link = setupLink();
    // Instantiate the compiler
    const compiler = this.webpack.webpack(this.config);

    // Clear garbage before compiling
    compiler.hooks.watchRun.tapPromise('tgui-dev-server', async () => {
      const files = await resolveGlob(this.bundleDir, '*.hot-update.*');
      logger.log(`clearing garbage (${files.length} files)`);
      for (const file of files) {
        await Bun.file(file).delete();
      }
      logger.log('compiling');
    });

    // Start reloading when it's finished
    compiler.hooks.done.tap('tgui-dev-server', async () => {
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
        ?.toString(this.config.devServer?.stats)
        .split('\n')
        .forEach((line) => logger.log(line));
    });
  }
}
