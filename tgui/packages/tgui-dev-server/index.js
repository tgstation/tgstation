/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { reloadByondCache } from './reloader.js';
import { createCompiler } from './webpack.js';

const noHot = process.argv.includes('--no-hot');
const noTmp = process.argv.includes('--no-tmp');
const reloadOnce = process.argv.includes('--reload');

const setupServer = async () => {
  const compiler = await createCompiler({
    mode: 'development',
    hot: !noHot,
    devServer: true,
    useTmpFolder: !noTmp,
  });
  // Reload cache once
  if (reloadOnce) {
    await reloadByondCache(compiler.bundleDir);
    return;
  }
  // Run a development server
  await compiler.watch();
};

setupServer();
