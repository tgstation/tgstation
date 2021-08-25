/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const createBabelConfig = options => {
  const { mode, presets = [], plugins = [] } = options;
  return {
    presets: [
      [require.resolve('@babel/preset-typescript'), {
        allowDeclareFields: true,
      }],
      [require.resolve('@babel/preset-env'), {
        modules: 'commonjs',
        useBuiltIns: 'entry',
        corejs: '3',
        spec: false,
        loose: true,
        targets: [],
      }],
      ...presets,
    ],
    plugins: [
      [require.resolve('@babel/plugin-proposal-class-properties'), {
        loose: true,
      }],
      require.resolve('@babel/plugin-transform-jscript'),
      require.resolve('babel-plugin-inferno'),
      require.resolve('babel-plugin-transform-remove-console'),
      require.resolve('common/string.babel-plugin.cjs'),
      ...plugins,
    ],
  };
};

module.exports = api => {
  api.cache(true);
  const mode = process.env.NODE_ENV;
  return createBabelConfig({ mode });
};

module.exports.createBabelConfig = createBabelConfig;
