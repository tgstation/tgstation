#!/usr/bin/env node

/**
 * Build script for /tg/station 13 codebase.
 *
 * This script uses Juke Build, read the docs here:
 * https://github.com/stylemistake/juke-build
 */

import fs from 'node:fs';
import Bun from 'bun';
import Juke from './juke/index.js';
import { bun, bunRoot } from './lib/bun';
import { DreamDaemon, DreamMaker, NamedVersionFile } from './lib/byond';
import { downloadFile } from './lib/download';
import { formatDeps } from './lib/helpers';
import { prependDefines } from './lib/tgs';

export const TGS_MODE = process.env.CBT_BUILD_MODE === 'TGS';

export const DME_NAME = 'tgstation';

Juke.chdir('../..', import.meta.url);

const dependencies: Record<string, any> = await Bun.file('dependencies.sh')
  .text()
  .then(formatDeps)
  .catch((err) => {
    Juke.logger.error(
      'Failed to read dependencies.sh, please ensure it exists and is formatted correctly.',
    );
    Juke.logger.error(err);
    throw new Juke.ExitCode(1);
  });

// Canonical path for the cutter exe at this moment
function getCutterPath() {
  const ver = dependencies.CUTTER_VERSION;
  const suffix = process.platform === 'win32' ? '.exe' : '';
  const file_ver = ver.split('.').join('-');

  return `tools/icon_cutter/cache/hypnagogic${file_ver}${suffix}`;
}

const cutter_path = getCutterPath();

export const DefineParameter = new Juke.Parameter({
  type: 'string[]',
  alias: 'D',
});

export const PortParameter = new Juke.Parameter({
  type: 'string',
  alias: 'p',
});

export const DmVersionParameter = new Juke.Parameter({
  type: 'string',
});

export const CiParameter = new Juke.Parameter({ type: 'boolean' });

export const ForceRecutParameter = new Juke.Parameter({
  type: 'boolean',
  name: 'force-recut',
});

export const SkipIconCutter = new Juke.Parameter({
  type: 'boolean',
  name: 'skip-icon-cutter',
});

export const WarningParameter = new Juke.Parameter({
  type: 'string[]',
  alias: 'W',
});

export const NoWarningParameter = new Juke.Parameter({
  type: 'string[]',
  alias: 'I',
});

export const CutterTarget = new Juke.Target({
  onlyWhen: () => {
    const files = Juke.glob(cutter_path);
    return files.length === 0;
  },
  executes: async () => {
    const repo = dependencies.CUTTER_REPO;
    const ver = dependencies.CUTTER_VERSION;
    const suffix = process.platform === 'win32' ? '.exe' : '';
    const download_from = `https://github.com/${repo}/releases/download/${ver}/hypnagogic${suffix}`;
    await downloadFile(download_from, cutter_path);
    if (process.platform !== 'win32') {
      await Juke.exec('chmod', ['+x', cutter_path]);
    }
  },
});

export const IconCutterTarget = new Juke.Target({
  parameters: [ForceRecutParameter],
  dependsOn: () => [CutterTarget],
  inputs: () => {
    const standard_inputs = [
      `icons/**/*.png.toml`,
      `icons/**/*.dmi.toml`,
      `cutter_templates/**/*.toml`,
      cutter_path,
    ];
    // Alright we're gonna search out any existing toml files and convert
    // them to their matching .dmi or .png file
    const existing_configs = [
      ...Juke.glob(`icons/**/*.png.toml`),
      ...Juke.glob(`icons/**/*.dmi.toml`),
    ];
    return [
      ...standard_inputs,
      ...existing_configs.map((file) => file.replace('.toml', '')),
    ];
  },
  outputs: ({ get }) => {
    if (get(ForceRecutParameter)) return [];
    const folders = [
      ...Juke.glob(`icons/**/*.png.toml`),
      ...Juke.glob(`icons/**/*.dmi.toml`),
    ];
    return folders
      .map((file) => file.replace(`.png.toml`, '.dmi'))
      .map((file) => file.replace(`.dmi.toml`, '.png'));
  },
  executes: async () => {
    await Juke.exec(cutter_path, [
      '--dont-wait',
      '--templates',
      'cutter_templates',
      'icons',
    ]);
  },
});

export const DmMapsIncludeTarget = new Juke.Target({
  executes: async () => {
    const folders = [
      ...Juke.glob('_maps/map_files/**/modular_pieces/*.dmm'),
      ...Juke.glob('_maps/RandomRuins/**/*.dmm'),
      ...Juke.glob('_maps/RandomZLevels/**/*.dmm'),
      ...Juke.glob('_maps/shuttles/**/*.dmm'),
      ...Juke.glob('_maps/templates/**/*.dmm'),
    ];
    const content =
      folders
        .map((file) => file.replace('_maps/', ''))
        .map((file) => `#include "${file}"`)
        .join('\n') + '\n';
    fs.writeFileSync('_maps/templates.dm', content);
  },
});

export const DmTarget = new Juke.Target({
  parameters: [
    DefineParameter,
    DmVersionParameter,
    WarningParameter,
    NoWarningParameter,
    SkipIconCutter,
  ],
  dependsOn: ({ get }) => [
    get(DefineParameter).includes('ALL_TEMPLATES') && DmMapsIncludeTarget,
    !get(SkipIconCutter) && IconCutterTarget,
  ],
  inputs: [
    '_maps/map_files/generic/**',
    'maps/**/*.dm',
    'code/**',
    'html/**',
    'icons/**',
    'interface/**',
    'sound/**',
    'tgui/public/tgui.html',
    `${DME_NAME}.dme`,
    NamedVersionFile,
  ],
  outputs: ({ get }) => {
    if (get(DmVersionParameter)) {
      return []; // Always rebuild when dm version is provided
    }
    return [`${DME_NAME}.dmb`, `${DME_NAME}.rsc`];
  },
  executes: async ({ get }) => {
    await DreamMaker(`${DME_NAME}.dme`, {
      defines: ['CBT', ...get(DefineParameter)],
      warningsAsErrors: get(WarningParameter).includes('error'),
      ignoreWarningCodes: get(NoWarningParameter),
      namedDmVersion: get(DmVersionParameter),
    });
  },
});

export const DmTestTarget = new Juke.Target({
  parameters: [
    DefineParameter,
    DmVersionParameter,
    WarningParameter,
    NoWarningParameter,
  ],
  dependsOn: ({ get }) => [
    get(DefineParameter).includes('ALL_MAPS') && DmMapsIncludeTarget,
    IconCutterTarget,
  ],
  executes: async ({ get }) => {
    fs.copyFileSync(`${DME_NAME}.dme`, `${DME_NAME}.test.dme`);
    await DreamMaker(`${DME_NAME}.test.dme`, {
      defines: ['CBT', 'CIBUILDING', ...get(DefineParameter)],
      warningsAsErrors: get(WarningParameter).includes('error'),
      ignoreWarningCodes: get(NoWarningParameter),
      namedDmVersion: get(DmVersionParameter),
    });
    Juke.rm('data/logs/ci', { recursive: true });
    const options = {
      dmbFile: `${DME_NAME}.test.dmb`,
      namedDmVersion: get(DmVersionParameter),
    };
    await DreamDaemon(
      options,
      '-close',
      '-trusted',
      '-verbose',
      '-params',
      'log-directory=ci',
    );
    Juke.rm('*.test.*');
    try {
      const cleanRun = fs.readFileSync('data/logs/ci/clean_run.lk', 'utf-8');
      console.log(cleanRun);
    } catch (err) {
      Juke.logger.error('Test run was not clean, exiting');
      throw new Juke.ExitCode(1);
    }
  },
});

export const AutowikiTarget = new Juke.Target({
  parameters: [
    DefineParameter,
    DmVersionParameter,
    WarningParameter,
    NoWarningParameter,
  ],
  dependsOn: ({ get }) => [
    get(DefineParameter).includes('ALL_TEMPLATES') && DmMapsIncludeTarget,
    IconCutterTarget,
  ],
  outputs: ['data/autowiki_edits.txt'],
  executes: async ({ get }) => {
    fs.copyFileSync(`${DME_NAME}.dme`, `${DME_NAME}.test.dme`);
    await DreamMaker(`${DME_NAME}.test.dme`, {
      defines: ['CBT', 'AUTOWIKI', ...get(DefineParameter)],
      warningsAsErrors: get(WarningParameter).includes('error'),
      ignoreWarningCodes: get(NoWarningParameter),
      namedDmVersion: get(DmVersionParameter),
    });
    Juke.rm('data/autowiki_edits.txt');
    Juke.rm('data/autowiki_files', { recursive: true });
    Juke.rm('data/logs/ci', { recursive: true });

    const options = {
      dmbFile: `${DME_NAME}.test.dmb`,
      namedDmVersion: get(DmVersionParameter),
    };
    await DreamDaemon(
      options,
      '-close',
      '-trusted',
      '-verbose',
      '-params',
      'log-directory=ci',
    );
    Juke.rm('*.test.*');
    if (!fs.existsSync('data/autowiki_edits.txt')) {
      Juke.logger.error('Autowiki did not generate an output, exiting');
      throw new Juke.ExitCode(1);
    }
  },
});

export const BunTarget = new Juke.Target({
  parameters: [CiParameter],
  inputs: ['tgui/**/package.json'],
  executes: () => {
    return bun('install', '--frozen-lockfile', '--ignore-scripts');
  },
});

export const BiomeInstallTarget = new Juke.Target({
  dependsOn: [BunTarget],
  inputs: ['package.json', 'bun.lock'],
  onlyWhen: () => {
    return Juke.glob('node_modules/@biomejs/**').length === 0;
  },
  executes: () => {
    return bunRoot('install');
  },
});

export const TgFontTarget = new Juke.Target({
  dependsOn: [BunTarget],
  inputs: [
    'tgui/packages/tgfont/**/*.+(js|mjs|svg)',
    'tgui/packages/tgfont/package.json',
  ],
  outputs: [
    'tgui/packages/tgfont/dist/tgfont.css',
    'tgui/packages/tgfont/dist/tgfont.woff2',
  ],
  executes: async () => {
    await bun('tgfont:build');
    fs.mkdirSync('tgui/packages/tgfont/static', { recursive: true });
    fs.copyFileSync(
      'tgui/packages/tgfont/dist/tgfont.css',
      'tgui/packages/tgfont/static/tgfont.css',
    );
    fs.copyFileSync(
      'tgui/packages/tgfont/dist/tgfont.woff2',
      'tgui/packages/tgfont/static/tgfont.woff2',
    );
  },
});

export const TguiTarget = new Juke.Target({
  dependsOn: [BunTarget, BiomeInstallTarget],
  inputs: [
    'tgui/rspack.config.ts',
    'tgui/**/package.json',
    'tgui/packages/**/*.+(js|cjs|ts|tsx|jsx|scss)',
  ],
  outputs: [
    'tgui/public/tgui.bundle.css',
    'tgui/public/tgui.bundle.js',
    'tgui/public/tgui-panel.bundle.css',
    'tgui/public/tgui-panel.bundle.js',
    'tgui/public/tgui-say.bundle.css',
    'tgui/public/tgui-say.bundle.js',
  ],
  executes: () => bun('tgui:build'),
});

export const TguiTscTarget = new Juke.Target({
  dependsOn: [BunTarget],
  executes: () => bun('tgui:tsc'),
});

export const TguiTestTarget = new Juke.Target({
  parameters: [CiParameter],
  dependsOn: [BunTarget],
  executes: () => bun('tgui:test'),
});

export const BiomeCheckTarget = new Juke.Target({
  dependsOn: [BunTarget, BiomeInstallTarget],
  executes: () => bunRoot('tgui:lint'),
});

export const TguiLintTarget = new Juke.Target({
  dependsOn: [BunTarget, BiomeCheckTarget, TguiTscTarget],
});

export const TguiDevTarget = new Juke.Target({
  dependsOn: [BunTarget],
  executes: ({ args }) => bun('tgui:dev', ...args),
});

export const TguiAnalyzeTarget = new Juke.Target({
  dependsOn: [BunTarget],
  executes: () => bun('tgui:analyze'),
});

export const TestTarget = new Juke.Target({
  dependsOn: [DmTestTarget, TguiTestTarget],
});

export const LintTarget = new Juke.Target({
  dependsOn: [TguiLintTarget],
});

export const BuildTarget = new Juke.Target({
  dependsOn: [TguiTarget, DmTarget],
});

export const ServerTarget = new Juke.Target({
  parameters: [DmVersionParameter, PortParameter],
  dependsOn: [BuildTarget],
  executes: async ({ get }) => {
    const port = get(PortParameter) || '1337';
    const options = {
      dmbFile: `${DME_NAME}.dmb`,
      namedDmVersion: get(DmVersionParameter),
    };
    await DreamDaemon(options, port, '-trusted');
  },
});

export const AllTarget = new Juke.Target({
  dependsOn: [TestTarget, LintTarget, BuildTarget],
});

export const TguiCleanTarget = new Juke.Target({
  executes: async () => {
    Juke.rm('tgui/public/.tmp', { recursive: true });
    Juke.rm('tgui/public/*.map');
    Juke.rm('tgui/public/*.{chunk,bundle,hot-update}.*');
    Juke.rm('tgui/packages/tgfont/dist', { recursive: true });
    Juke.rm('tgui/node_modules', { recursive: true });
  },
});

export const CleanTarget = new Juke.Target({
  dependsOn: [TguiCleanTarget],
  executes: async () => {
    Juke.rm('*.{dmb,rsc}');
    Juke.rm('_maps/templates.dm');
  },
});

/**
 * Removes more junk at the expense of much slower initial builds.
 */
export const CleanAllTarget = new Juke.Target({
  dependsOn: [CleanTarget],
  executes: async () => {
    Juke.logger.info('Cleaning up data/logs');
    Juke.rm('data/logs', { recursive: true });
  },
});

export const TgsTarget = new Juke.Target({
  dependsOn: [TguiTarget],
  executes: async () => {
    Juke.logger.info('Prepending TGS define');
    prependDefines('TGS');
  },
});

Juke.setup({ file: import.meta.url }).then((code) => {
  // We're using the currently available quirk in Juke Build, which
  // prevents it from exiting on Windows, to wait on errors.
  if (code !== 0 && process.argv.includes('--wait-on-error')) {
    Juke.logger.error('Please inspect the error and close the window.');
    return;
  }

  if (TGS_MODE) {
    // workaround for ESBuild process lingering
    // Once https://github.com/privatenumber/esbuild-loader/pull/354 is merged and updated to, this can be removed
    setTimeout(() => process.exit(code), 10000);
  } else {
    process.exit(code);
  }
});

export default TGS_MODE ? TgsTarget : BuildTarget;
