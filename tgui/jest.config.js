module.exports = {
  roots: ['<rootDir>/packages'],
  testMatch: [
    '<rootDir>/packages/**/__tests__/*.{js,ts,tsx}',
    '<rootDir>/packages/**/*.{spec,test}.{js,ts,tsx}',
  ],
  testPathIgnorePatterns: [
    '<rootDir>/packages/tgui-bench',
  ],
  testEnvironment: 'jsdom',
  testRunner: require.resolve('jest-circus/runner'),
  transform: {
    '^.+\\.(js|cjs|ts|tsx)$': require.resolve('babel-jest'),
  },
  moduleFileExtensions: ['js', 'cjs', 'ts', 'tsx', 'json'],
  resetMocks: true,
};
