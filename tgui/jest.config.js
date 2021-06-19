module.exports = {
  roots: ['<rootDir>/packages'],
  testMatch: [
    '<rootDir>/packages/**/__tests__/*.{js,jsx,ts,tsx}',
    '<rootDir>/packages/**/*.{spec,test}.{js,jsx,ts,tsx}',
  ],
  testEnvironment: 'jsdom',
  testRunner: require.resolve('jest-circus/runner'),
  transform: {
    '^.+\\.(js|jsx|ts|tsx|cjs|mjs)$': require.resolve('babel-jest'),
  },
  moduleFileExtensions: ['js', 'jsx', 'ts', 'tsx', 'json'],
  resetMocks: true,
};
