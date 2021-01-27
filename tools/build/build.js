#!/usr/bin/env node
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { resolve: resolvePath } = require('path');
const { resolveGlob } = require('./cbt/fs');
const { exec } = require('./cbt/process');
const { Task, runTasks } = require('./cbt/task');
const { regQuery } = require('./cbt/winreg');

// Change working directory to project root
process.chdir(resolvePath(__dirname, '../../'));

const taskTgui = new Task('tgui')
  .depends('tgui/.yarn/releases/*')
  .depends('tgui/yarn.lock')
  .depends('tgui/webpack.config.js')
  .depends('tgui/**/package.json')
  .depends('tgui/packages/**/*.js')
  .depends('tgui/packages/**/*.jsx')
  .provides('tgui/public/tgui.bundle.css')
  .provides('tgui/public/tgui.bundle.js')
  .provides('tgui/public/tgui-common.bundle.js')
  .provides('tgui/public/tgui-panel.bundle.css')
  .provides('tgui/public/tgui-panel.bundle.js')
  .build(async () => {
    // Instead of calling `tgui/bin/tgui`, we reproduce the whole pipeline
    // here for maximum compilation speed.
    const yarnRelease = resolveGlob('./tgui/.yarn/releases/yarn-*.cjs')[0]
      .replace('/tgui/', '/');
    const yarn = args => exec('node', [yarnRelease, ...args], {
      cwd: './tgui',
    });
    await yarn(['install']);
    await yarn(['run', 'webpack-cli', '--mode=production']);
  });

const taskDm = new Task('dm')
  .depends('_maps/map_files/generic/**')
  .depends('code/**')
  .depends('goon/**')
  .depends('html/**')
  .depends('icons/**')
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
    await exec(compiler, ['tgstation.dme']);
  });

// Frontend
const tasksToRun = [
  taskTgui,
  taskDm,
];

if (process.env['TG_BUILD_TGS_MODE']) {
  tasksToRun.pop();
}

runTasks(tasksToRun);
