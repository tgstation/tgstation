const Juke = require('../juke');
const { stat } = require('./fs');
const { regQuery } = require('./winreg');
const fs = require('fs');

/**
 * Cached path to DM compiler
 */
let dmPath;

/**
 * DM compiler
 *
 * @param {string} dmeFile
 * @param {{ defines?: string[] }} options
 */
const dm = async (dmeFile, options = {}) => {
  // Get path to DM compiler
  if (!dmPath) {
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
  }
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
    fs.writeFileSync(`${dmeBaseName}.mdme`, injectedContent);
    const dmeContent = fs.readFileSync(`${dmeBaseName}.dme`);
    fs.appendFileSync(`${dmeBaseName}.mdme`, dmeContent);
    await Juke.exec(dmPath, [`${dmeBaseName}.mdme`]);
    fs.writeFileSync(`${dmeBaseName}.dmb`, fs.readFileSync(`${dmeBaseName}.mdme.dmb`));
    fs.writeFileSync(`${dmeBaseName}.rsc`, fs.readFileSync(`${dmeBaseName}.mdme.rsc`));
    fs.unlinkSync(`${dmeBaseName}.mdme.dmb`);
    fs.unlinkSync(`${dmeBaseName}.mdme.rsc`);
    fs.unlinkSync(`${dmeBaseName}.mdme`);
  }
  else {
    await Juke.exec(dmPath, [dmeFile]);
  }
};

module.exports = {
  dm,
};
