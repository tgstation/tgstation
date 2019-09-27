const webpack = require('webpack');
const path = require('path');
const BuildNotifierPlugin = require('webpack-build-notifier');
const ExtractCssChunks = require('extract-css-chunks-webpack-plugin');

module.exports = (env = {}, argv) => {
  const config = {
    mode: 'none',
    entry: {
      tgui: [
        'core-js/stable',
        'regenerator-runtime/runtime',
        'dom4',
        path.resolve(__dirname, './styles/main.scss'),
        path.resolve(__dirname, './index.js'),
      ],
    },
    output: {
      path: path.resolve(__dirname, './public/bundles'),
      publicPath: '/bundles/',
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
          exclude: /node_modules/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: [
                  ['@babel/preset-env', {
                    modules: false,
                    useBuiltIns: 'entry',
                    corejs: '3',
                    spec: true,
                    targets: {
                      ie: '8',
                    },
                  }],
                ],
                plugins: [
                  'babel-plugin-inferno',
                  'babel-plugin-lodash',
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
                hot: true,
              },
            },
            'css-loader',
            'sass-loader',
          ],
        },
        {
          test: /\.css$/,
          use: [
            {
              loader: ExtractCssChunks.loader,
              options: {
                hot: true,
              },
            },
            'css-loader',
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
    plugins: [
      new webpack.EnvironmentPlugin({
        NODE_ENV: env.NODE_ENV || argv.mode || 'development',
      }),
      new ExtractCssChunks({
        filename: '[name].bundle.css',
        chunkFilename: '[name].chunk.css',
        orderWarning: true,
      }),
    ],
  };

  // Add a bundle analyzer to the plugins array
  if (env.analyze) {
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
    config.mode = 'production';
    config.devtool = 'cheap-module-source-map';
    config.performance = {
      hints: false,
    };
    config.optimization.minimizer = [
      new TerserPlugin({
        terserOptions: {
          ie8: true,
          output: {
            ascii_only: true,
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
  else {
    config.mode = 'development';
    config.plugins = [
      ...config.plugins,
      new BuildNotifierPlugin(),
    ];
    config.devtool = 'cheap-module-source-map';
    config.devServer = {
      // Mandatory settings
      port: 3000,
      publicPath: '/bundles/',
      contentBase: 'public',
      historyApiFallback: {
        index: '/index.html',
      },
      // Hot module replacement
      hot: true,
      // Informational flags
      progress: false,
      quiet: false,
      noInfo: false,
      // Fine-grained logging control
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
