/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from 'node:fs';

import { reloadByondCache } from './reloader';
import { RspackCompiler } from './webpack';

const reloadOnce = process.argv.includes('--reload');

async function setupServer() {
  fs.mkdirSync('./public/.tmp', { recursive: true });

  const compiler = new RspackCompiler();

  await compiler.setup();

  // Reload cache once
  if (reloadOnce) {
    await reloadByondCache(compiler.bundleDir);
    return;
  }

  // Run a development server
  await compiler.watch();
}

setupServer();
