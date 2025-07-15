import path from 'node:path';

import { defineConfig } from '@rspack/cli';
import rspack, { type StatsOptions } from '@rspack/core';

export function createStats(verbose: boolean): StatsOptions {
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

const dirname = path.resolve();

export default defineConfig({
  context: dirname,
  devtool: false,
  entry: {
    tgui: './packages/tgui',
    'tgui-panel': './packages/tgui-panel',
    'tgui-say': './packages/tgui-say',
  },
  mode: 'production',
  module: {
    rules: [
      {
        test: /\.([tj]s(x)?|cjs)$/,
        type: 'javascript/auto',
        use: [
          {
            loader: 'builtin:swc-loader',
            options: {
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
      },
      {
        test: /\.(s)?css$/,
        type: 'javascript/auto',
        use: [
          rspack.CssExtractRspackPlugin.loader,
          'css-loader',
          {
            loader: 'sass-loader',
            options: {
              api: 'modern-compiler',
              implementation: 'sass-embedded',
            },
          },
        ],
      },
      {
        test: /\.(png|jpg)$/,
        type: 'asset/resource',
        generator: {
          filename: '[name][ext]',
        },
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
        generator: {
          filename: '[name][ext]',
        },
      },
    ],
  },
  optimization: {
    emitOnErrors: false,
  },
  output: {
    path: 'public',
    filename: '[name].bundle.js',
    chunkFilename: '[name].bundle.js',
    chunkLoadTimeout: 15000,
    publicPath: '/',
    assetModuleFilename: '[name][ext]',
  },
  performance: {
    hints: false,
  },
  plugins: [
    new rspack.CssExtractRspackPlugin({
      chunkFilename: '[name].bundle.css',
      filename: '[name].bundle.css',
    }),
    new rspack.EnvironmentPlugin({
      NODE_ENV: 'production',
    }),
  ],
  resolve: {
    extensions: ['.tsx', '.ts', '.js', '.jsx'],
    alias: {
      tgui: path.resolve(dirname, './packages/tgui'),
      'tgui-panel': path.resolve(dirname, './packages/tgui-panel'),
      'tgui-say': path.resolve(dirname, './packages/tgui-say'),
      'tgui-dev-server': path.resolve(dirname, './packages/tgui-dev-server'),
    },
  },
  stats: createStats(true),
  target: ['web', 'browserslist:edge >= 123'],
});
