import { mkdirSync } from 'node:fs';
import Juke from '../juke/index.js';

let hasInstallFolder = false;

export function bun(dir: string, ...args: any[]): Promise<Juke.ExecReturn> {
  if (!hasInstallFolder) {
    mkdirSync(`${dir}/node_modules/`, { recursive: true });
    hasInstallFolder = true;
  }

  return Juke.exec('bun', [...args.filter((arg) => typeof arg === 'string')], {
    cwd: dir,
    shell: true,
  });
}
