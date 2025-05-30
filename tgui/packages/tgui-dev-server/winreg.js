/**
 * Tools for dealing with Windows Registry bullshit.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { exec } from 'node:child_process';
import { promisify } from 'node:util';

import { createLogger } from './logging.js';

const logger = createLogger('winreg');

/**
 * Query a registry key.
 * @param {string} path
 * @param {string} key
 * @return {Promise<string>}
 */
export async function regQuery(path, key) {
  if (process.platform !== 'win32') {
    return;
  }
  try {
    const command = `reg query "${path}" /v ${key}`;
    const { stdout } = await promisify(exec)(command);
    const keyPattern = `    ${key}    `;
    const indexOfKey = stdout.indexOf(keyPattern);

    if (indexOfKey === -1) {
      logger.error('could not find the registry key');
      return;
    }

    const indexOfEol = stdout.indexOf('\r\n', indexOfKey);
    if (indexOfEol === -1) {
      logger.error('could not find the end of the line');
      return;
    }

    const indexOfValue = stdout.indexOf('    ', indexOfKey + keyPattern.length);
    if (indexOfValue === -1) {
      logger.error('could not find the start of the key value');
      return;
    }

    return stdout.substring(indexOfValue + 4, indexOfEol);
  } catch (err) {
    logger.error(err);
    return;
  }
}
