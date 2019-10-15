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
