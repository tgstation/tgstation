const { exec } = require('../juke');
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
  const { defines } = options;
  const dmeBaseName = dmeFile.replace(/\.dme$/, '');
  if (defines && defines.length > 0) {
    const injectedContent = defines
      .map(x => `#define ${x}\n`)
      .join('');
    fs.writeFileSync(`${dmeBaseName}.mdme`, injectedContent)
    const dmeContent = fs.readFileSync(`${dmeBaseName}.dme`)
    fs.appendFileSync(`${dmeBaseName}.mdme`, dmeContent)
    await exec(dmPath, [`${dmeBaseName}.mdme`]);
    fs.renameSync(`${dmeBaseName}.mdme.dmb`, `${dmeBaseName}.dmb`)
    fs.renameSync(`${dmeBaseName}.mdme.rsc`, `${dmeBaseName}.rsc`)
    fs.unlinkSync(`${dmeBaseName}.mdme`)
  }
  else {
    await exec(dmPath, dmeFile);
  }
};

module.exports = {
  dm,
};
