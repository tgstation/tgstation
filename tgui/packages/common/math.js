/**
 * Limits a number to the range between 'min' and 'max'.
 */
export const clamp = (value, min = 0, max = 1) => {
  return Math.max(min, Math.min(value, max));
};

/**
 * Returns a rounded number.
 * TODO: Replace this native rounding function with a more robust one.
 */
export const round = value => Math.round(value);

/**
 * Returns a string representing a number in fixed point notation.
 */
export const toFixed = (value, fractionDigits = 0) => {
  return Number(value).toFixed(fractionDigits);
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
