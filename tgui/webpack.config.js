/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const webpack = require('webpack');
const path = require('path');
const ExtractCssPlugin = require('mini-css-extract-plugin');

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

module.exports = (env = {}, argv) => {
  const mode = argv.mode || 'production';
  const bench = env.TGUI_BENCH;
  const config = {
    mode: mode === 'production' ? 'production' : 'development',
    context: path.resolve(__dirname),
    target: ['web', 'es5', 'browserslist:ie 11'],
    entry: {
      tgui: ['./packages/tgui-polyfill', './packages/tgui'],
      'tgui-panel': ['./packages/tgui-polyfill', './packages/tgui-panel'],
      'tgui-say': ['./packages/tgui-polyfill', './packages/tgui-say'],
    },
    output: {
      path: argv.useTmpFolder
        ? path.resolve(__dirname, './public/.tmp')
        : path.resolve(__dirname, './public'),
      filename: '[name].bundle.js',
      chunkFilename: '[name].bundle.js',
      chunkLoadTimeout: 15000,
      publicPath: '/',
    },
    resolve: {
      extensions: ['.tsx', '.ts', '.js', '.jsx'],
      alias: {},
    },
    module: {
      rules: [
        {
          test: /\.([tj]s(x)?|cjs)$/,
          use: [
            {
              loader: require.resolve('swc-loader'),
            },
          ],
        },
        {
          test: /\.scss$/,
          use: [
            {
              loader: ExtractCssPlugin.loader,
              options: {
                esModule: false,
              },
            },
            {
              loader: require.resolve('css-loader'),
              options: {
                esModule: false,
              },
            },
            {
              loader: require.resolve('sass-loader'),
            },
          ],
        },
        {
          test: /\.(png|jpg|svg)$/,
          use: [
            {
              loader: require.resolve('url-loader'),
              options: {
                esModule: false,
              },
            },
          ],
        },
      ],
    },
    optimization: {
      emitOnErrors: false,
    },
    performance: {
      hints: false,
    },
    devtool: false,
    cache: {
      type: 'filesystem',
      cacheLocation: path.resolve(__dirname, `.yarn/webpack/${mode}`),
      buildDependencies: {
        config: [__filename],
      },
    },
    stats: createStats(true),
    plugins: [
      new webpack.EnvironmentPlugin({
        NODE_ENV: env.NODE_ENV || mode,
        WEBPACK_HMR_ENABLED: env.WEBPACK_HMR_ENABLED || argv.hot || false,
        DEV_SERVER_IP: env.DEV_SERVER_IP || null,
      }),
      new ExtractCssPlugin({
        filename: '[name].bundle.css',
        chunkFilename: '[name].bundle.css',
      }),
    ],
  };

  if (bench) {
    config.entry = {
      'tgui-bench': [
        './packages/tgui-polyfill',
        './packages/tgui-bench/entrypoint',
      ],
    };
  }

  // Production build specific options
  if (mode === 'production') {
    const { EsbuildPlugin } = require('esbuild-loader');
    config.optimization.minimizer = [
      new EsbuildPlugin({
        target: 'ie11',
        css: true,
      }),
    ];
  }

  // Development build specific options
  if (mode !== 'production') {
    config.devtool = 'cheap-module-source-map';
  }

  // Development server specific options
  if (argv.devServer) {
    config.devServer = {
      progress: false,
      quiet: false,
      noInfo: false,
      clientLogLevel: 'silent',
      stats: createStats(false),
    };
  }

  return config;
};
