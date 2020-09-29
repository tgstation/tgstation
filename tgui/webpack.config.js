/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const webpack = require('webpack');
const path = require('path');
const BuildNotifierPlugin = require('webpack-build-notifier');
const ExtractCssChunks = require('extract-css-chunks-webpack-plugin');
const PnpPlugin = require(`pnp-webpack-plugin`);

const createStats = verbose => ({
  assets: verbose,
  builtAt: verbose,
  cached: false,
  children: false,
  chunks: false,
  colors: true,
  hash: false,
  timings: verbose,
  version: verbose,
  modules: false,
});

module.exports = (env = {}, argv) => {
  const config = {
    mode: argv.mode === 'production' ? 'production' : 'development',
    context: path.resolve(__dirname),
    entry: {
      'tgui': [
        './packages/tgui-polyfill',
        './packages/tgui',
      ],
      'tgui-panel': [
        './packages/tgui-polyfill',
        './packages/tgui-panel',
      ],
    },
    output: {
      path: argv.useTmpFolder
        ? path.resolve(__dirname, './public/.tmp')
        : path.resolve(__dirname, './public'),
      filename: '[name].bundle.js',
      chunkFilename: '[name].chunk.js',
    },
    resolve: {
      extensions: ['.js', '.jsx'],
      alias: {},
      plugins: [
        PnpPlugin,
      ],
    },
    resolveLoader: {
      plugins: [
        PnpPlugin.moduleLoader(module),
      ],
    },
    module: {
      rules: [
        {
          test: /\.m?jsx?$/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: [
                  ['@babel/preset-env', {
                    modules: 'commonjs',
                    useBuiltIns: 'entry',
                    corejs: '3.6',
                    spec: false,
                    loose: true,
                    targets: {
                      ie: '8',
                    },
                  }],
                ],
                plugins: [
                  '@babel/plugin-transform-jscript',
                  'babel-plugin-inferno',
                  'babel-plugin-transform-remove-console',
                  'common/string.babel-plugin.cjs',
                ],
              },
            },
          ],
        },
        {
          test: /\.scss$/,
          use: [
            {
              loader: ExtractCssChunks.loader,
              options: {
                hmr: argv.hot,
              },
            },
            {
              loader: 'css-loader',
              options: {},
            },
            {
              loader: 'sass-loader',
              options: {},
            },
          ],
        },
        {
          test: /\.(png|jpg|svg)$/,
          use: [
            {
              loader: 'url-loader',
              options: {},
            },
          ],
        },
      ],
    },
    optimization: {
      noEmitOnErrors: true,
      splitChunks: {
        chunks: 'initial',
        name: 'tgui-common',
      },
    },
    performance: {
      hints: false,
    },
    devtool: false,
    stats: createStats(true),
    plugins: [
      new webpack.EnvironmentPlugin({
        NODE_ENV: env.NODE_ENV || argv.mode || 'development',
        WEBPACK_HMR_ENABLED: env.WEBPACK_HMR_ENABLED || argv.hot || false,
        DEV_SERVER_IP: env.DEV_SERVER_IP || null,
      }),
      new ExtractCssChunks({
        filename: '[name].bundle.css',
        chunkFilename: '[name].chunk.css',
        orderWarning: true,
      }),
    ],
  };

  // Add a bundle analyzer to the plugins array
  if (argv.analyze) {
    const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
    config.plugins = [
      ...config.plugins,
      new BundleAnalyzerPlugin(),
    ];
  }

  // Production build specific options
  if (argv.mode === 'production') {
    const TerserPlugin = require('terser-webpack-plugin');
    const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
    config.optimization.minimizer = [
      new TerserPlugin({
        extractComments: false,
        terserOptions: {
          ie8: true,
          output: {
            ascii_only: true,
            comments: false,
          },
        },
      }),
    ];
    config.plugins = [
      ...config.plugins,
      new OptimizeCssAssetsPlugin({
        assetNameRegExp: /\.css$/g,
        cssProcessor: require('cssnano'),
        cssProcessorPluginOptions: {
          preset: ['default', {
            discardComments: {
              removeAll: true,
            },
          }],
        },
        canPrint: true,
      }),
    ];
  }

  // Development build specific options
  if (argv.mode !== 'production') {
    if (argv.hot) {
      config.plugins.push(new webpack.HotModuleReplacementPlugin());
    }
    config.devtool = 'cheap-module-source-map';
  }

  // Development server specific options
  if (argv.devServer) {
    config.plugins = [
      ...config.plugins,
      new BuildNotifierPlugin({
        suppressSuccess: true,
      }),
    ];
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
