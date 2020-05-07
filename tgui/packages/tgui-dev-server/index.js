/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { setupWebpack, getWebpackConfig } from './webpack.js';
import { reloadByondCache } from './reloader.js';

const noHot = process.argv.includes('--no-hot');
const reloadOnce = process.argv.includes('--reload');

const setupServer = async () => {
  const config = await getWebpackConfig({
    mode: 'development',
    hot: !noHot,
  });
  // Reload cache once
  if (reloadOnce) {
    const bundleDir = config.output.path;
    await reloadByondCache(bundleDir);
    return;
  }
  // Run a development server
  await setupWebpack(config);
};

setupServer();
