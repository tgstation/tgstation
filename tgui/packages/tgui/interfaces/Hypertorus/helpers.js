
export const to_exponential_if_big = (value) => {
  if (value > 5000) {
    return value.toExponential(1);
  }
  return Math.round(value);
}
