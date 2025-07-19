import { mkdirSync } from 'node:fs';
import Juke from '../juke/index.js';

let hasInstallFolder = false;

export function bun(...args: any[]): Promise<Juke.ExecReturn> {
  if (!hasInstallFolder) {
    mkdirSync('./tgui/node_modules/', { recursive: true });
    hasInstallFolder = true;
  }

  return Juke.exec('bun', [...args.filter((arg) => typeof arg === 'string')], {
    cwd: './tgui',
    shell: true,
  });
}

export function bunRoot(...args: any[]): Promise<Juke.ExecReturn> {
  if (!hasInstallFolder) {
    mkdirSync('./node_modules/', { recursive: true });
    hasInstallFolder = true;
  }

  return Juke.exec('bun', [...args.filter((arg) => typeof arg === 'string')], {
    cwd: './',
    shell: true,
  });
}
