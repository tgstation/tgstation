#!/usr/bin/env node
/**
 * Build script for /tg/station 13 codebase.
 *
 * This script uses Juke Build, read the docs here:
 * https://github.com/stylemistake/juke-build
 *
 * @file
 * @copyright 2021 Aleksej Komarov
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

// Main
// --------------------------------------------------------

const fs = require('fs');
const Juke = require('./juke');
const { yarn } = require('./cbt/yarn');
const { dm } = require('./cbt/dm');

const DME_NAME = 'tgstation';

const YarnTarget = Juke.createTarget({
  name: 'yarn',
  inputs: [
    'tgui/.yarn/+(cache|releases|plugins|sdks)/**/*',
    'tgui/**/package.json',
    'tgui/yarn.lock',
  ],
  outputs: [
    'tgui/.yarn/install-target',
  ],
  executes: () => yarn('install'),
});

const TgFontTarget = Juke.createTarget({
  name: 'tgfont',
  dependsOn: [YarnTarget],
  inputs: [
    'tgui/.yarn/install-target',
    'tgui/packages/tgfont/**/*.+(js|cjs|svg)',
    'tgui/packages/tgfont/package.json',
  ],
  outputs: [
    'tgui/packages/tgfont/dist/tgfont.css',
    'tgui/packages/tgfont/dist/tgfont.eot',
    'tgui/packages/tgfont/dist/tgfont.woff2',
  ],
  executes: () => yarn('workspace', 'tgfont', 'build'),
});

const TguiTarget = Juke.createTarget({
  name: 'tgui',
  dependsOn: [YarnTarget],
  inputs: [
    'tgui/.yarn/install-target',
    'tgui/webpack.config.js',
    'tgui/**/package.json',
    'tgui/packages/**/*.+(js|cjs|ts|tsx|scss)',
  ],
  outputs: [
    'tgui/public/tgui.bundle.css',
    'tgui/public/tgui.bundle.js',
    'tgui/public/tgui-common.bundle.js',
    'tgui/public/tgui-panel.bundle.css',
    'tgui/public/tgui-panel.bundle.js',
  ],
  executes: () => yarn('run', 'webpack-cli', '--mode=production'),
});

const DefineParameter = Juke.createParameter({
  type: 'string[]',
  name: 'define',
  alias: 'D',
});

const DmTarget = Juke.createTarget({
  name: 'dm',
  inputs: [
    '_maps/map_files/generic/**',
    'code/**',
    'goon/**',
    'html/**',
    'icons/**',
    'interface/**',
    `${DME_NAME}.dme`,
  ],
  outputs: [
    `${DME_NAME}.dmb`,
    `${DME_NAME}.rsc`,
  ],
  parameters: [DefineParameter],
  executes: async ({ get }) => {
    const defines = get(DefineParameter);
    if (defines.length > 0) {
      Juke.logger.info('Using defines:', defines.join(', '));
    }
    await dm(`${DME_NAME}.dme`, {
      defines: ['CBT', ...defines],
    });
  },
});

const DefaultTarget = Juke.createTarget({
  name: 'default',
  dependsOn: [TguiTarget, TgFontTarget, DmTarget],
});

/**
 * Prepends the defines to the .dme.
 * Does not clean them up, as this is intended for TGS which
 * clones new copies anyway.
 */
const prependDefines = (...defines) => {
  const dmeContents = fs.readFileSync(`${DME_NAME}.dme`);
  const textToWrite = defines.map(define => `#define ${define}\n`);
  fs.writeFileSync(`${DME_NAME}.dme`, `${textToWrite}\n${dmeContents}`);
};

const TgsTarget = Juke.createTarget({
  name: 'tgs',
  dependsOn: [TguiTarget, TgFontTarget],
  executes: async () => {
    Juke.logger.info('Prepending TGS define');
    prependDefines('TGS');
  },
});

const TGS_MODE = process.env.CBT_BUILD_MODE === 'TGS';

Juke
  .setup({
    default: TGS_MODE ? TgsTarget : DefaultTarget,
  })
  .then((code) => {
    process.exit(code);
  });
