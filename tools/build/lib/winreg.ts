/**
 * Tools for dealing with Windows Registry bullshit.
 *
 * Adapted from `tgui/packages/tgui-dev-server/winreg.js`.
 *
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { exec } from "node:child_process";
import { promisify } from "node:util";

export async function regQuery(
  path: string,
  key: string,
): Promise<string | string[] | undefined> {
  if (process.platform !== "win32") {
    return;
  }
  try {
    const command = `reg query "${path}" /v ${key}`;
    const { stdout } = await promisify(exec)(command);
    const keyPattern = `    ${key}    `;
    const indexOfKey = stdout.indexOf(keyPattern);
    if (indexOfKey === -1) {
      return;
    }
    const indexOfEol = stdout.indexOf("\r\n", indexOfKey);
    if (indexOfEol === -1) {
      return;
    }
    const indexOfValue = stdout.indexOf("    ", indexOfKey + keyPattern.length);
    if (indexOfValue === -1) {
      return;
    }
    const value = stdout.substring(indexOfValue + 4, indexOfEol);
    return value;
  } catch (err) {
    return;
  }
}
