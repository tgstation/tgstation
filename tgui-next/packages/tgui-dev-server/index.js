import { setupLink } from './link/server.js';
import { setupWebpack, getWebpackConfig } from './webpack.js';
import { reloadByondCache } from './reloader.js';

const hot = process.platform === 'win32'
  || process.argv.includes('--hot');

const reloadOnce = process.argv.includes('--reload-once');

const setupServer = async () => {
  const config = await getWebpackConfig({
    mode: 'development',
    hot,
  });
  // Reload cache once
  if (reloadOnce) {
    const bundleDir = config.output.path;
    await reloadByondCache(bundleDir);
    return;
  }
  // Run a development server
  const link = setupLink();
  await setupWebpack(link, config);
};

setupServer();
