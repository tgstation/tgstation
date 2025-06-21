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
  const config = {
    mode,
    context: path.resolve(__dirname),
    target: ['web', 'browserslist:edge>=123'],
    entry: {
      tgui: ['./packages/tgui'],
      'tgui-panel': ['./packages/tgui-panel'],
      'tgui-say': ['./packages/tgui-say'],
    },
    output: {
      path:
        mode !== 'production'
          ? path.resolve(__dirname, './public/.tmp')
          : path.resolve(__dirname, './public'),
      filename: '[name].bundle.js',
      chunkFilename: '[name].bundle.js',
      chunkLoadTimeout: 15000,
      publicPath: '/',
    },
    resolve: {
      extensions: ['.tsx', '.ts', '.js', '.jsx'],
      alias: {
        tgui: path.resolve(__dirname, './packages/tgui'),
        'tgui-panel': path.resolve(__dirname, './packages/tgui-panel'),
        'tgui-say': path.resolve(__dirname, './packages/tgui-say'),
        'tgui-dev-server': path.resolve(
          __dirname,
          './packages/tgui-dev-server',
        ),
      },
    },
    module: {
      rules: [
        {
          test: /\.([tj]s(x)?|cjs)$/,
          exclude: /node_modules/,
          use: [
            {
              loader: require.resolve('swc-loader'),
            },
          ],
        },
        {
          test: /\.(s)?css$/,
          use: [
            ExtractCssPlugin.loader,
            require.resolve('css-loader'),
            require.resolve('sass-loader'),
          ],
        },

        {
          test: /\.(cur|png|jpg)$/,
          type: 'asset/resource',
        },
        {
          test: /.svg$/,
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
    optimization: {
      emitOnErrors: false,
    },
    performance: {
      hints: false,
    },
    devtool: false,
    cache: {
      type: 'filesystem',
      cacheLocation: path.resolve(
        __dirname,
        `node_modules/.cache/webpack/${mode}`,
      ),
      buildDependencies: {
        config: [__filename],
      },
    },
    stats: createStats(true),
    plugins: [
      new webpack.EnvironmentPlugin({
        NODE_ENV: mode,
      }),
      new ExtractCssPlugin({
        filename: '[name].bundle.css',
        chunkFilename: '[name].bundle.css',
      }),
    ],
  };

  // Production build specific options
  if (mode === 'production') {
    const { EsbuildPlugin } = require('esbuild-loader');
    config.optimization.minimizer = [
      new EsbuildPlugin({
        css: true,
        legalComments: 'none',
      }),
    ];
  } else {
    config.devServer = {
      clientLogLevel: 'silent',
      hot: true,
      noInfo: false,
      progress: false,
      quiet: false,
      stats: createStats(false),
    };
    config.devtool = 'cheap-module-source-map';
  }

  return config;
};
