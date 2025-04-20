import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: [
      'packages/**/__tests__/*.{ts,tsx}',
      'packages/**/*.{spec,test}.{ts,tsx}',
    ],
    exclude: ['packages/tgui-bench/**/*'],
    environment: 'jsdom',
    restoreMocks: true,
  },
});
