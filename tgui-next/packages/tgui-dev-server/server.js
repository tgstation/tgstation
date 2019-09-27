import fs from 'fs';
import glob from 'glob';
import { createLogger, directLog } from 'logging';
import { createRequire } from 'module';
import os from 'os';
import path from 'path';
import util from 'util';
import webpack from 'webpack';
import ws from 'ws';

const setupServer = () => {
  const logger = createLogger('server');
  const socket = new ws.Server({
    port: 3001,
  });

  let clientCounter = 0;

  socket.on('connection', ws => {
    const clientId = ++clientCounter;
    logger.log(`client ${clientId} connected`);

    ws.on('message', msg => {
      const { type, payload } = JSON.parse(msg);
      if (type === 'log') {
        const { ns, args } = payload;
        directLog(ns, ...args);
        return;
      }
    });

    ws.on('close', () => {
      logger.log(`client ${clientId} disconnected`);
    });
  });

  logger.log('listening');
};

const setupWebpack = async () => {
  const logger = createLogger('webpack');
  logger.log('setting up');
  const require = createRequire(import.meta.url);
  const createConfig = await require('tgui/webpack.config.js');
  const config = createConfig({}, {
    mode: 'development',
  });
  const statsConfig = config.devServer.stats;
  const compiler = webpack(config);

  // Start the compiler in watch mode
  logger.log('watching for changes');
  compiler.watch({}, (err, stats) => {
    if (err) {
      logger.error('compilation error', err);
      return;
    }
    logger.log(stats.toString(statsConfig));
    reloadByondCache(config.output.path);
  });
};

const reloadByondCache = async bundleDir => {
  const logger = createLogger('reloader');
  // First asterisk is an unknown location of "Documents" folder,
  // since it can be localized by the OS.
  const cachePattern = path.resolve(os.homedir(), './*/BYOND/cache/tmp*');
  const cacheDirs = await util.promisify(glob)(cachePattern, {});
  if (cacheDirs.length === 0) {
    logger.log(`found no cache directories`);
    return;
  }
  // Start the actual reloading
  const assetPattern = path.resolve(bundleDir, './*.bundle.*');
  const assets = await util.promisify(glob)(assetPattern);
  for (let cacheDir of cacheDirs) {
    for (let asset of assets) {
      const destination = path.resolve(cacheDir, path.basename(asset));
      await util.promisify(fs.copyFile)(asset, destination);
    }
    logger.log(`copied ${assets.length} files to ${cacheDir}`);
  }
};

setupServer();
setupWebpack();
