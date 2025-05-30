/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { mkdirSync } from 'node:fs';

import { reloadByondCache } from './reloader';
import { createCompiler } from './webpack';

const noHot = process.argv.includes('--no-hot');
const noTmp = process.argv.includes('--no-tmp');
const reloadOnce = process.argv.includes('--reload');

async function setupServer() {
  mkdirSync('./public/.tmp', { recursive: true });

  const compiler = await createCompiler({
    hot: !noHot,
    useTmpFolder: !noTmp,
  });

  // Reload cache once
  if (reloadOnce) {
    await reloadByondCache(compiler.bundleDir);
    return;
  }

  // Run a development server
  await compiler.watch();
}

setupServer();
