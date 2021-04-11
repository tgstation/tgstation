#!/usr/bin/env node
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Change working directory to project root
process.chdir(require('path').resolve(__dirname, '../../'));

// Validate NodeJS version
const NODE_VERSION = parseInt(process.versions.node.match(/(\d+)/)[1]);
const NODE_VERSION_TARGET = parseInt(require('fs')
  .readFileSync('dependencies.sh', 'utf-8')
  .match(/NODE_VERSION=(\d+)/)[1]);
if (NODE_VERSION < NODE_VERSION_TARGET) {
  console.error('Your current Node.js version is out of date.');
  console.error('You have two options:');
  console.error('  a) Go to https://nodejs.org/ and install the latest LTS release of Node.js');
  console.error('  b) Uninstall Node.js (our build system automatically downloads one)');
  process.exit(1);
}

const STANDARD_BUILD = "Standard Build"
const TGS_BUILD = "TGS Build"
const ALL_MAPS_BUILD = "CI All Maps Build"
const TEST_RUN_BUILD = "CI Integration Tests Build"
const NO_DM_BUILD = "Except DM Build"

let BUILD_MODE = STANDARD_BUILD;
if (process.env.CBT_BUILD_MODE) {
  switch (process.env.CBT_BUILD_MODE) {
    case "ALL_MAPS":
      BUILD_MODE = ALL_MAPS_BUILD
      break;
    case "TEST_RUN":
      BUILD_MODE = TEST_RUN_BUILD
      break;
    case "TGS":
      BUILD_MODE = TGS_BUILD
      break;
    case "NO_DM":
      BUILD_MODE = NO_DM_BUILD
      break;
    default:
      BUILD_MODE = process.env.CBT_BUILD_MODE
      break;
  }
}
console.log(`Starting CBT in ${BUILD_MODE} mode.`)

const DME_NAME = 'tgstation'

// Main
// --------------------------------------------------------

const { resolveGlob, stat } = require('./cbt/fs');
const { exec } = require('./cbt/process');
const { Task, runTasks } = require('./cbt/task');
const { regQuery } = require('./cbt/winreg');
const fs = require('fs');

const yarn = args => {
  const yarnPath = resolveGlob('./tgui/.yarn/releases/yarn-*.cjs')[0]
    .replace('/tgui/', '/');
  return exec('node', [yarnPath, ...args], {
    cwd: './tgui',
  });
};

/** Installs all tgui dependencies */
const taskYarn = new Task('yarn')
  // The following dependencies skip what could be considered an important
  // step in Yarn: it verifies the integrity of cache. With this setup, if
  // cache ever becomes corrupted, your only option is to clean build.
  .depends('tgui/.yarn/+(cache|releases|plugins|sdks)/**/*')
  .depends('tgui/**/package.json')
  .depends('tgui/yarn.lock')
  // Phony target (automatically created at the end of the task)
  .provides('tgui/.yarn/install-target')
  .build(() => yarn(['install']));

/** Builds svg fonts */
const taskTgfont = new Task('tgfont')
  .depends('tgui/.yarn/install-target')
  .depends('tgui/packages/tgfont/**/*.+(js|cjs|svg)')
  .depends('tgui/packages/tgfont/package.json')
  .provides('tgui/packages/tgfont/dist/tgfont.css')
  .provides('tgui/packages/tgfont/dist/tgfont.eot')
  .provides('tgui/packages/tgfont/dist/tgfont.woff2')
  .build(() => yarn(['workspace', 'tgfont', 'build']));

/** Builds tgui */
const taskTgui = new Task('tgui')
  .depends('tgui/.yarn/install-target')
  .depends('tgui/webpack.config.js')
  .depends('tgui/**/package.json')
  .depends('tgui/packages/**/*.+(js|cjs|ts|tsx|scss)')
  .provides('tgui/public/tgui.bundle.css')
  .provides('tgui/public/tgui.bundle.js')
  .provides('tgui/public/tgui-common.bundle.js')
  .provides('tgui/public/tgui-panel.bundle.css')
  .provides('tgui/public/tgui-panel.bundle.js')
  .build(async () => {
    await yarn(['run', 'webpack-cli', '--mode=production']);
  });

/**
 * Prepends the defines to the .dme.
 * Does not clean them up, as this is intended for TGS which
 * clones new copies anyway.
 */
const taskPrependDefines = (...defines) => new Task('prepend-defines')
  .build(async () => {
    const dmeContents = fs.readFileSync(`${DME_NAME}.dme`);
    const textToWrite = defines.map(define => `#define ${define}\n`);
    fs.writeFileSync(`${DME_NAME}.dme`, `${textToWrite}\n${dmeContents}`);
  });

const taskDm = (...injectedDefines) => new Task('dm')
  .depends('_maps/map_files/generic/**')
  .depends('code/**')
  .depends('goon/**')
  .depends('html/**')
  .depends('icons/**')
  .depends('interface/**')
  .depends('tgui/public/tgui.html')
  .depends('tgui/public/*.bundle.*')
  .depends(`${DME_NAME}.dme`)
  .provides(`${DME_NAME}.dmb`)
  .provides(`${DME_NAME}.rsc`)
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
    if (injectedDefines.length) {
        const injectedContent = injectedDefines
          .map(x => `#define ${x}\n`)
          .join('')
        // Create mdme file
        fs.writeFileSync(`${DME_NAME}.mdme`, injectedContent)
        // Add the actual dme content
        const dme_content = fs.readFileSync(`${DME_NAME}.dme`)
        fs.appendFileSync(`${DME_NAME}.mdme`, dme_content)
        await exec(dmPath, [`${DME_NAME}.mdme`]);
        // Rename dmb
        fs.renameSync(`${DME_NAME}.mdme.dmb`, `${DME_NAME}.dmb`)
        // Rename rsc
        fs.renameSync(`${DME_NAME}.mdme.rsc`, `${DME_NAME}.rsc`)
        // Remove mdme
        fs.unlinkSync(`${DME_NAME}.mdme`)
    }
    else {
      await exec(dmPath, [`${DME_NAME}.dme`]);
    }
  });

// Frontend
let tasksToRun = [
  taskYarn,
  taskTgfont,
  taskTgui,
];
switch (BUILD_MODE) {
  case STANDARD_BUILD:
    tasksToRun.push(taskDm('CBT'));
    break;
  case TGS_BUILD:
    tasksToRun.push(taskPrependDefines('TGS'));
    break;
  case ALL_MAPS_BUILD:
    tasksToRun.push(taskDm('CBT','CIBUILDING','CITESTING','ALL_MAPS'));
    break;
  case TEST_RUN_BUILD:
    tasksToRun.push(taskDm('CBT','CIBUILDING'));
    break;
  case NO_DM_BUILD:
    break;
  default:
    console.error(`Unknown build mode : ${BUILD_MODE}`)
    break;
}

runTasks(tasksToRun);
