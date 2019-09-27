/**
 * Helper to limit a number to be inside 'min' and 'max'.
 */
export const clamp = (min, max, value) =>
  Math.max(min, Math.min(value, max));

/**
 * Helper to round a number to 'decimals' decimals.
 */
export const fixed = (value, decimals = 1) =>
  Number(Math.round(value + 'e' + decimals) + 'e-' + decimals);
