import { Config } from '@jest/types';

const config: Config.InitialOptions = {
  roots: ['<rootDir>/packages'],
  testMatch: [
    '<rootDir>/packages/**/__tests__/*.{js,ts,tsx}',
    '<rootDir>/packages/**/*.{spec,test}.{js,ts,tsx}',
  ],
  testPathIgnorePatterns: ['<rootDir>/packages/tgui-bench'],
  testEnvironment: 'jsdom',
  testRunner: 'jest-circus/runner',
  transform: {
    '^.+\\.(js|cjs|ts|tsx)$': '@swc/jest',
  },
  moduleFileExtensions: ['js', 'cjs', 'ts', 'tsx', 'json'],
  resetMocks: true,
};

export default config;
