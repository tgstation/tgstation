import fs from 'fs';
import path from 'path';
import Juke from '../juke/index.js';
import { regQuery } from './winreg.js';

/**
 * Cached path to DM compiler
 */
let dmPath;

const getDmPath = async () => {
  if (dmPath) {
    return dmPath;
  }
  dmPath = await (async () => {
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
        return fs.statSync(path).isFile();
      }
      catch (err) {
        return false;
      }
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
  return dmPath;
};

/**
 * @param {string} dmeFile
 * @param {{ defines?: string[] }} options
 */
export const DreamMaker = async (dmeFile, options = {}) => {
  const dmPath = await getDmPath();
  // Get project basename
  const dmeBaseName = dmeFile.replace(/\.dme$/, '');
  // Make sure output files are writable
  const testOutputFile = (name) => {
    try {
      fs.closeSync(fs.openSync(name, 'r+'));
    }
    catch (err) {
      if (err && err.code === 'ENOENT') {
        return;
      }
      if (err && err.code === 'EBUSY') {
        Juke.logger.error(`File '${name}' is locked by the DreamDaemon process.`);
        Juke.logger.error(`Stop the currently running server and try again.`);
        throw new Juke.ExitCode(1);
      }
      throw err;
    }
  };
  testOutputFile(`${dmeBaseName}.dmb`);
  testOutputFile(`${dmeBaseName}.rsc`);
  // Compile
  const { defines } = options;
  if (defines && defines.length > 0) {
    const injectedContent = defines
      .map(x => `#define ${x}\n`)
      .join('');
    fs.writeFileSync(`${dmeBaseName}.m.dme`, injectedContent);
    const dmeContent = fs.readFileSync(`${dmeBaseName}.dme`);
    fs.appendFileSync(`${dmeBaseName}.m.dme`, dmeContent);
    await Juke.exec(dmPath, [`${dmeBaseName}.m.dme`]);
    fs.writeFileSync(`${dmeBaseName}.dmb`, fs.readFileSync(`${dmeBaseName}.m.dmb`));
    fs.writeFileSync(`${dmeBaseName}.rsc`, fs.readFileSync(`${dmeBaseName}.m.rsc`));
    fs.unlinkSync(`${dmeBaseName}.m.dmb`);
    fs.unlinkSync(`${dmeBaseName}.m.rsc`);
    fs.unlinkSync(`${dmeBaseName}.m.dme`);
  }
  else {
    await Juke.exec(dmPath, [dmeFile]);
  }
};

export const DreamDaemon = async (dmbFile, ...args) => {
  const dmPath = await getDmPath();
  const baseDir = path.dirname(dmPath);
  const ddExeName = process.platform === 'win32' ? 'dd.exe' : 'DreamDaemon';
  const ddExePath = baseDir === '.' ? ddExeName : path.join(baseDir, ddExeName);
  return Juke.exec(ddExePath, [dmbFile, ...args]);
};
