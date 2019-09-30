import fs from 'fs';
import glob from 'glob';
import { createLogger, directLog } from 'logging';
import { createRequire } from 'module';
import os from 'os';
import path from 'path';
import util from 'util';
import webpack from 'webpack';
import WebSocket from 'ws';

const logger = createLogger('server');

const setupServer = async () => {
  const port = 3000;
  const wss = new WebSocket.Server({ port });

  setupClientEndpoint(wss);
  await setupWebpack(wss);

  logger.log(`listening on port ${port}`);
  return { wss };
};

const broadcastMessage = (wss, msg) => {
  const clients = [...wss.clients];
  logger.log(`broadcasting ${msg.type} to ${clients.length} clients`);
  for (let client of clients) {
    const json = JSON.stringify(msg);
    client.send(json);
  }
};

const setupClientEndpoint = wss => {
  wss.on('connection', ws => {
    logger.log('client connected');

    ws.on('message', msg => {
      const { type, payload } = JSON.parse(msg);
      if (type === 'log') {
        const { ns, args } = payload;
        directLog(ns, ...args);
        return;
      }
    });

    ws.on('close', () => {
      logger.log('client disconnected');
    });
  });
};

const getWebpackConfig = async () => {
  const require = createRequire(import.meta.url);
  const createConfig = await require('tgui/webpack.config.js');
  const config = createConfig({}, {
    mode: 'development',
  });
  return config;
};

const setupWebpack = async wss => {
  const logger = createLogger('webpack');
  logger.log('setting up');
  const config = await getWebpackConfig();
  const bundleDir = config.output.path;
  // Add HMR webpack plugin
  config.plugins.push(new webpack.HotModuleReplacementPlugin());
  // Instantiate the compiler
  const compiler = webpack(config);
  // Clear garbage before compiling
  compiler.hooks.watchRun.tapPromise('tgui-dev-server', async () => {
    const files = await resolvePath(bundleDir, './*.hot-update.*');
    logger.log(`clearing garbage (${files.length} files)`);
    for (let file of files) {
      await util.promisify(fs.unlink)(file);
    }
  });
  // Start reloading when it's finished
  compiler.hooks.done.tap('tgui-dev-server', async stats => {
    await reloadByondCache(bundleDir);
    // Notify all clients that update has happened
    broadcastMessage(wss, {
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
    logger.log(stats.toString(config.devServer.stats));
  });
};

/**
 * Combines path.resolve with glob patterns.
 */
const resolvePath = (...sections) => {
  return util.promisify(glob)(path.resolve(...sections));
};

const reloadByondCache = async bundleDir => {
  const logger = createLogger('reloader');
  // First asterisk is an unknown location of "Documents" folder,
  // since it can be localized by the OS.
  const cacheDirs = await resolvePath(os.homedir(), './*/BYOND/cache/tmp*');
  if (cacheDirs.length === 0) {
    logger.log('found no cache directories');
    return;
  }
  // Start the actual reloading
  const assets = await resolvePath(bundleDir, './*.+(bundle|hot-update).*');
  // Clear garbage
  for (let cacheDir of cacheDirs) {
    const garbage = await resolvePath(cacheDir, './*.+(bundle|hot-update).*');
    for (let file of garbage) {
      await util.promisify(fs.unlink)(file);
    }
  }
  // Copy assets
  for (let cacheDir of cacheDirs) {
    for (let asset of assets) {
      const destination = path.resolve(cacheDir, path.basename(asset));
      await util.promisify(fs.copyFile)(asset, destination);
    }
    logger.log(`copied ${assets.length} files to ${cacheDir}`);
  }
};

setupServer();
