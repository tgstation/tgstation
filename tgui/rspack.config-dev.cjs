const { defineConfig } = require('@rspack/cli');
const { rspack } = require('@rspack/core');

const createStats = (verbose) => ({
  assets: verbose,
  builtAt: verbose,
  cached: false,
  children: false,
  chunks: false,
  colors: true,
  entrypoints: true,
  hash: false,
  modules: false,
  performance: false,
  timings: verbose,
  version: verbose,
});

/**
 * 04/25/2025
 * There is a bug in rspack, possibly only ours, with the experimental css
 * feature that throws an error in tgui-dev. This prevents hot reloading from
 * working properly and there doesn't seem to be any way to fix it.
 *
 * This config exists to switch to the old css loader during development.
 *
 * `TypeError: Cannot read properties of null (reading 'removeChild')`
 */
module.exports = (env = {}, argv) => {
  /** @type {import('@rspack/core').Configuration} */
  const config = defineConfig({
    cache: false,
    experiments: undefined,
    mode: 'development',
    module: {
      rules: [
        {
          test: /\.([tj]s(x)?|cjs)$/,
          use: [
            {
              loader: 'builtin:swc-loader',
              options: {
                isModule: 'unknown',
                jsc: {
                  parser: {
                    syntax: 'typescript',
                    tsx: true,
                  },
                  transform: {
                    react: {
                      runtime: 'automatic',
                    },
                  },
                },
              },
            },
          ],
          type: 'javascript/auto',
        },
        {
          test: /\.(s)?css$/,
          use: [
            {
              loader: rspack.CssExtractRspackPlugin.loader,
            },
            {
              loader: require.resolve('css-loader'),
            },
            {
              loader: require.resolve('sass-loader'),
              options: {
                api: 'modern-compiler',
                implementation: 'sass-embedded',
              },
            },
          ],
          type: 'javascript/auto',
        },
        {
          test: /\.(png|jpg)$/,
          type: 'asset/resource',
        },
        {
          test: /\.svg$/,
          oneOf: [
            {
              issuer: /\.(s)?css$/,
              type: 'asset/inline',
            },
            {
              type: 'asset/resource',
            },
          ],
        },
      ],
    },
    plugins: [
      new rspack.EnvironmentPlugin({
        NODE_ENV: 'development',
        WEBPACK_HMR_ENABLED: env.WEBPACK_HMR_ENABLED || argv.hot || false,
        DEV_SERVER_IP: env.DEV_SERVER_IP || null,
      }),
      new rspack.CssExtractRspackPlugin({
        filename: '[name].bundle.css',
        chunkFilename: '[name].bundle.css',
      }),
    ],
  });
  config.devtool = 'cheap-module-source-map';
  config.devServer = {
    progress: false,
    quiet: false,
    noInfo: false,
    clientLogLevel: 'silent',
    stats: createStats(false),
  };

  return config;
};
