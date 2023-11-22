import { defineConfig } from 'vite';
import inferno from 'vite-plugin-inferno';
import path from 'path';
import legacy from '@vitejs/plugin-legacy';

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
      },
    },
  },
  plugins: [
    inferno(),
    legacy({
      targets: ['ie >= 11'],
      additionalLegacyPolyfills: ['regenerator-runtime/runtime'],
      renderModernChunks: false,
    }),
  ],
  resolve: {
    alias: {
      '~tgui': path.resolve(__dirname, 'packages/tgui'),
    },
  },
});
