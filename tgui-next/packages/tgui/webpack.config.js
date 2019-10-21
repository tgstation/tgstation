const webpack = require('webpack');
const path = require('path');
const BuildNotifierPlugin = require('webpack-build-notifier');
const ExtractCssChunks = require('extract-css-chunks-webpack-plugin');

module.exports = (env = {}, argv) => {
  const config = {
    mode: argv.mode === 'production' ? 'production' : 'development',
    context: __dirname,
    entry: {
      tgui: [
        path.resolve(__dirname, './styles/main.scss'),
        path.resolve(__dirname, './index.js'),
      ],
    },
    output: {
      path: path.resolve(__dirname, './public/bundles'),
      filename: '[name].bundle.js',
      chunkFilename: '[name].chunk.js',
    },
    resolve: {
      extensions: ['.mjs', '.js', '.jsx'],
      alias: {},
    },
    module: {
      rules: [
        {
          test: /\.m?jsx?$/,
          // exclude: /node_modules/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: [
                  ['@babel/preset-env', {
                    modules: 'commonjs',
                    useBuiltIns: 'entry',
                    corejs: '3',
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
                hot: argv.hot,
              },
            },
            {
              loader: 'css-loader',
              options: {
                url: false,
              },
            },
            {
              loader: 'sass-loader',
              options: {},
            },
          ],
        },
        {
          test: /\.css$/,
          use: [
            {
              loader: ExtractCssChunks.loader,
              options: {
                hot: argv.hot,
              },
            },
            {
              loader: 'css-loader',
              options: {
                url: false,
              },
            },
          ],
        },
        {
          test: /\.(png|jpg|gif|ico)$/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: 'images/[name].[ext]',
              },
            },
          ],
        },
        {
          test: /\.(ttf|woff|woff2|eot|svg)$/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: 'fonts/[name].[ext]',
              },
            },
          ],
        },
      ],
    },
    optimization: {
      noEmitOnErrors: true,
      // splitChunks: {
      //   cacheGroups: {
      //     commons: {
      //       test: /[\\/]node_modules[\\/]/,
      //       name: 'vendor',
      //       chunks: 'all',
      //     },
      //   },
      // },
    },
    performance: {
      hints: false,
    },
    // Unfortunately, source maps don't work with BYOND's IE.
    devtool: false,
    plugins: [
      new webpack.EnvironmentPlugin({
        NODE_ENV: env.NODE_ENV || argv.mode || 'development',
        WEBPACK_HMR_ENABLED: env.WEBPACK_HMR_ENABLED || argv.hot || false,
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

  // Production specific options
  if (argv.mode === 'production') {
    const TerserPlugin = require('terser-webpack-plugin');
    const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
    config.optimization.minimizer = [
      new TerserPlugin({
        extractComments: false,
        terserOptions: {
          ie8: true,
          // mangle: false,
          output: {
            ascii_only: true,
            // beautify: true,
            // indent_level: 2,
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

  // Development specific options
  if (argv.mode !== 'production') {
    config.plugins = [
      ...config.plugins,
      new BuildNotifierPlugin(),
    ];
    if (argv.hot) {
      config.plugins.push(new webpack.HotModuleReplacementPlugin());
    }
    config.devServer = {
      // Informational flags
      progress: false,
      quiet: false,
      noInfo: false,
      // Fine-grained logging control
      clientLogLevel: 'silent',
      stats: {
        assets: false,
        builtAt: false,
        cached: false,
        children: false,
        chunks: false,
        colors: true,
        hash: false,
        timings: false,
        version: false,
        modules: false,
      },
    };
  }

  return config;
};
