import { defineConfig } from 'vite';
import inferno from 'vite-plugin-inferno';
import legacy from '@vitejs/plugin-legacy';
import path from 'path';

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        tgui: path.resolve(__dirname, 'packages/tgui'),
        'tgui-panel': path.resolve(__dirname, 'packages/tgui-panel'),
        'tgui-say': path.resolve(__dirname, 'packages/tgui-say'),
      },
      output: {
        entryFileNames: `[name].js`,
        assetFileNames: `[name].[ext]`,
      },
    },
  },
  plugins: [
    inferno(),
    legacy({
      targets: ['ie 11'],
      renderModernChunks: false,
    }),
  ],
  resolve: {
    alias: {
      '~tgui': path.resolve(__dirname, 'packages/tgui'),
    },
  },
});
