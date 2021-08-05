const { exec, resolveGlob } = require('../juke');

let yarnPath;

const yarn = (...args) => {
  if (!yarnPath) {
    yarnPath = resolveGlob('./tgui/.yarn/releases/yarn-*.cjs')[0]
      .replace('/tgui/', '/');
  }
  return exec('node', [yarnPath, ...args], {
    cwd: './tgui',
  });
};

module.exports = {
  yarn,
};
