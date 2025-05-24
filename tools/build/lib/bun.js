
import Juke from "../juke/index.js";
import {mkdirSync} from "node:fs";

let bunPath;
let hasInstallFolder = false;

export function bun(...args) {
  if (!bunPath) {
    bunPath = Juke.glob('./tools/build/node_modules/.bin/bun')[0]
  }

  if (!hasInstallFolder) {
    mkdirSync('./tgui/node_modules/', { recursive: true });
    hasInstallFolder = true;
  }

  return Juke.exec(bunPath, [
    ...args.filter((arg) => typeof arg === 'string'),
  ], {
    cwd: './tgui',
    shell: true,
  });
}
