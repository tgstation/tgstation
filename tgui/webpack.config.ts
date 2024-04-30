/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { EsbuildPlugin } from 'esbuild-loader';
import ExtractCssPlugin from 'mini-css-extract-plugin';
import path from 'path';
import { dirname } from 'path';
import { fileURLToPath } from 'url';
import webpack from 'webpack';
import { type Configuration } from 'webpack';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

type Env = Partial<{
  DEV_SERVER_IP: string;
  NODE_ENV: string;
  TGUI_BENCH: string;
  WEBPACK_HMR_ENABLED: string;
}>;

type Args = {
  devServer: boolean;
  hot: boolean;
  mode: 'development' | 'production';
  useTmpFolder: boolean;
};

type DevServerOptions = {
  clientLogLevel: string;
  noInfo: boolean;
  progress: boolean;
  quiet: boolean;
  stats: Record<string, boolean>;
};

type TguiConfig = {
  devServer?: DevServerOptions;
  devtool: string | false;
} & Configuration;

function createStats(verbose: boolean) {
  return {
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
  };
}

export default (env: Env = {}, argv: Args): Configuration => {
  const mode = argv.mode || 'production';
  const bench = env.TGUI_BENCH;

  const config: TguiConfig = {
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
              loader: 'swc-loader',
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
              loader: 'css-loader',
              options: {
                esModule: false,
              },
            },
            {
              loader: 'sass-loader',
            },
          ],
        },
        {
          test: /\.(png|jpg|svg)$/,
          use: [
            {
              loader: 'url-loader',
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
    config.optimization!.minimizer = [
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
