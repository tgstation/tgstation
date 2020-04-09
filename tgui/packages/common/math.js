/**
 * Limits a number to the range between 'min' and 'max'.
 */
export const clamp = (value, min, max) => {
  return Math.max(min, Math.min(value, max));
};

/**
 * Limits a number between 0 and 1.
 */
export const clamp01 = value => clamp(value, 0, 1);

/**
 * Scales a number to fit into the range between min and max.
 */
export const scale = (value, min, max) => {
  return (value - min) / (max - min);
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
