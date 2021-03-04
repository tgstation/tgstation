/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Limits a number to the range between 'min' and 'max'.
 */
export const clamp = (value, min, max) => {
  return value < min ? min : value > max ? max : value;
};

/**
 * Limits a number between 0 and 1.
 */
export const clamp01 = value => {
  return value < 0 ? 0 : value > 1 ? 1 : value;
};

/**
 * Scales a number to fit into the range between min and max.
 */
export const scale = (value, min, max) => {
  return (value - min) / (max - min);
};

/**
 * Robust number rounding.
 *
 * Adapted from Locutus, see: http://locutus.io/php/math/round/
 *
 * @param  {number} value
 * @param  {number} precision
 * @return {number}
 */
export const round = (value, precision) => {
  if (!value || isNaN(value)) {
    return value;
  }
  // helper variables
  let m, f, isHalf, sgn;
  // making sure precision is integer
  precision |= 0;
  m = Math.pow(10, precision);
  value *= m;
  // sign of the number
  sgn = (value > 0) | -(value < 0);
  // isHalf = value % 1 === 0.5 * sgn;
  isHalf = Math.abs(value % 1) >= 0.4999999999854481;
  f = Math.floor(value);
  if (isHalf) {
    // rounds .5 away from zero
    value = f + (sgn > 0);
  }
  return (isHalf ? value : Math.round(value)) / m;
};

/**
 * Returns a string representing a number in fixed point notation.
 */
export const toFixed = (value, fractionDigits = 0) => {
  return Number(value).toFixed(Math.max(fractionDigits, 0));
};

/**
 * Checks whether a value is within the provided range.
 *
 * Range is an array of two numbers, for example: [0, 15].
 */
export const inRange = (value, range) => {
  return range
    && value >= range[0]
    && value <= range[1];
};

/**
 * Walks over the object with ranges, comparing value against every range,
 * and returns the key of the first matching range.
 *
 * Range is an array of two numbers, for example: [0, 15].
 */
export const keyOfMatchingRange = (value, ranges) => {
  for (let rangeName of Object.keys(ranges)) {
    const range = ranges[rangeName];
    if (inRange(value, range)) {
      return rangeName;
    }
  }
};

/**
 * Get number of digits following the decimal point in a number
 */
export const numberOfDecimalDigits = value => {
  if (Math.floor(value) !== value) {
    return value.toString().split('.')[1].length || 0;
  }
  return 0;
};
