import { clamp } from './math';

/**
 * Returns random number between lowerBound exclusive and upperBound inclusive
 */
export const randomNumber = (lowerBound: number, upperBound: number) => {
  return Math.random() * (upperBound - lowerBound) + lowerBound;
};

/**
 * Returns random integer between lowerBound exclusive and upperBound inclusive
 */
export const randomInteger = (lowerBound: number, upperBound: number) => {
  lowerBound = Math.ceil(lowerBound);
  upperBound = Math.floor(upperBound);
  return Math.floor(Math.random() * (upperBound - lowerBound) + lowerBound);
};

/**
 * Returns random array element
 */
export const randomPick = <T>(array: T[]) => {
  return array[Math.floor(Math.random() * array.length)];
};

/**
 * Return 1 with probability P percent; otherwise 0
 */
export const randomProb = (probability: number) => {
  const normalized = clamp(probability, 0, 100) / 100;
  return Math.random() <= normalized;
};
