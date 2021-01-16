#!/usr/bin/env node
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { resolve: resolvePath } = require('path');
const { Task, runTasks, exec, regQuery } = require('./cbt');

// Change working directory to project root
process.chdir(resolvePath(__dirname, '../../'));

const taskTgui = new Task('tgui')
  .depends('tgui/.yarn/releases/*')
  .depends('tgui/yarn.lock')
  .depends('tgui/**/package.json')
  .depends('tgui/packages/**/*.js')
  .depends('tgui/packages/**/*.jsx')
  .provides('tgui/public/*.bundle.*')
  .provides('tgui/public/*.chunk.*')
  .build(async () => {
    if (process.platform === 'win32') {
      await exec('powershell.exe',
        '-NoLogo', '-ExecutionPolicy', 'Bypass',
        '-File', 'tgui/bin/tgui.ps1');
    }
    else {
      await exec('tgui/bin/tgui');
    }
  });

const taskDm = new Task('dm')
  .depends('code/**')
  .depends('goon/**')
  .depends('html/**')
  .depends('interface/**')
  .depends('tgui/public/tgui.html')
  .depends('tgui/public/*.bundle.*')
  .depends('tgui/public/*.chunk.*')
  .depends('tgstation.dme')
  .provides('tgstation.dmb')
  .provides('tgstation.rsc')
  .build(async () => {
    let compiler = 'dm';
    // Let's do some registry queries on Windows, because dm is not in PATH.
    if (process.platform === 'win32') {
      const installPath = (
        await regQuery(
          'HKLM\\Software\\Dantom\\BYOND',
          'installpath')
        || await regQuery(
          'HKLM\\SOFTWARE\\WOW6432Node\\Dantom\\BYOND',
          'installpath')
      );
      if (installPath) {
        compiler = resolvePath(installPath, 'bin/dm.exe');
      }
    } else {
      compiler = 'DreamMaker';
    }
    await exec(compiler, 'tgstation.dme');
  });

// Frontend
let tasksToRun = [
  taskTgui,
  taskDm,
];

if (process.env['TG_BUILD_TGS_MODE']) {
  tasksToRun.pop();
}

runTasks(tasksToRun);
