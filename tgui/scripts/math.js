// Extensions to the built-in 'Math' object.

// Helper to limit a number to be inside 'min' and 'max'.
export function clamp (min, max) {
  return Math.max(min, Math.min(number, max))
}

// Helper to round a number to 'decimals' decimals.
export function fixed (number, decimals = 1) {
  return Number(Math.round(number + 'e' + decimals) + 'e-' + decimals)
}
