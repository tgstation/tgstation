#!/usr/bin/env node
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { resolve: resolvePath } = require('path');
const { resolveGlob, stat } = require('./cbt/fs');
const { exec } = require('./cbt/process');
const { Task, runTasks } = require('./cbt/task');
const { regQuery } = require('./cbt/winreg');

// Change working directory to project root
process.chdir(resolvePath(__dirname, '../../'));

const taskTgui = new Task('tgui')
  .depends('tgui/.yarn/releases/*')
  .depends('tgui/.yarn/install-state.gz')
  .depends('tgui/yarn.lock')
  .depends('tgui/webpack.config.js')
  .depends('tgui/**/package.json')
  .depends('tgui/packages/**/*.+(js|jsx|ts|tsx|cjs|mjs|scss)')
  .provides('tgui/public/tgui.bundle.css')
  .provides('tgui/public/tgui.bundle.js')
  .provides('tgui/public/tgui-common.bundle.js')
  .provides('tgui/public/tgui-panel.bundle.css')
  .provides('tgui/public/tgui-panel.bundle.js')
  .build(async () => {
    // Instead of calling `tgui/bin/tgui`, we reproduce the whole pipeline
    // here for maximum compilation speed.
    const yarnPath = resolveGlob('./tgui/.yarn/releases/yarn-*.cjs')[0]
      .replace('/tgui/', '/');
    const yarn = args => exec('node', [yarnPath, ...args], {
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
  .depends('tgstation.dme')
  .provides('tgstation.dmb')
  .provides('tgstation.rsc')
  .build(async () => {
    const dmPath = await (async () => {
      // Search in array of paths
      const paths = [
        ...((process.env.DM_EXE && process.env.DM_EXE.split(',')) || []),
        'C:\\Program Files\\BYOND\\bin\\dm.exe',
        'C:\\Program Files (x86)\\BYOND\\bin\\dm.exe',
        ['reg', 'HKLM\\Software\\Dantom\\BYOND', 'installpath'],
        ['reg', 'HKLM\\SOFTWARE\\WOW6432Node\\Dantom\\BYOND', 'installpath'],
      ];
      const isFile = path => {
        try {
          const fstat = stat(path);
          return fstat && fstat.isFile();
        }
        catch (err) {}
        return false;
      };
      for (let path of paths) {
        // Resolve a registry key
        if (Array.isArray(path)) {
          const [type, ...args] = path;
          path = await regQuery(...args);
        }
        if (!path) {
          continue;
        }
        // Check if path exists
        if (isFile(path)) {
          return path;
        }
        if (isFile(path + '/dm.exe')) {
          return path + '/dm.exe';
        }
        if (isFile(path + '/bin/dm.exe')) {
          return path + '/bin/dm.exe';
        }
      }
      // Default paths
      return (
        process.platform === 'win32' && 'dm.exe'
        || 'DreamMaker'
      );
    })();
    await exec(dmPath, ['tgstation.dme']);
  });

// Frontend
const tasksToRun = [
  taskTgui,
  taskDm,
];

if (process.env.TG_BUILD_TGS_MODE) {
  tasksToRun.pop();
}

runTasks(tasksToRun);
