/**
 * Tools for dealing with Windows Registry bullshit.
 *
 * Adapted from `tgui/packages/tgui-dev-server/winreg.js`.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { exec } = require('child_process');
const { promisify } = require('util');

const regQuery = async (path, key) => {
  if (process.platform !== 'win32') {
    return null;
  }
  try {
    const command = `reg query "${path}" /v ${key}`;
    const { stdout } = await promisify(exec)(command);
    const keyPattern = `    ${key}    `;
    const indexOfKey = stdout.indexOf(keyPattern);
    if (indexOfKey === -1) {
      return null;
    }
    const indexOfEol = stdout.indexOf('\r\n', indexOfKey);
    if (indexOfEol === -1) {
      return null;
    }
    const indexOfValue = stdout.indexOf(
      '    ',
      indexOfKey + keyPattern.length);
    if (indexOfValue === -1) {
      return null;
    }
    const value = stdout.substring(indexOfValue + 4, indexOfEol);
    return value;
  }
  catch (err) {
    return null;
  }
};

module.exports = {
  regQuery,
};
