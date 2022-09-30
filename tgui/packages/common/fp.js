/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Creates a function that returns the result of invoking the given
 * functions, where each successive invocation is supplied the return
 * value of the previous.
 */
// prettier-ignore
export const flow = (...funcs) => (input, ...rest) => {
  let output = input;
  for (let func of funcs) {
    // Recurse into the array of functions
    if (Array.isArray(func)) {
      output = flow(...func)(output, ...rest);
    }
    else if (func) {
      output = func(output, ...rest);
    }
  }
  return output;
};

/**
 * Composes single-argument functions from right to left.
 *
 * All functions might accept a context in form of additional arguments.
 * If the resulting function is called with more than 1 argument, rest of
 * the arguments are passed to all functions unchanged.
 *
 * @param {...Function} funcs The functions to compose
 * @returns {Function} A function obtained by composing the argument functions
 * from right to left. For example, compose(f, g, h) is identical to doing
 * (input, ...rest) => f(g(h(input, ...rest), ...rest), ...rest)
 */
export const compose = (...funcs) => {
  if (funcs.length === 0) {
    return (arg) => arg;
  }
  if (funcs.length === 1) {
    return funcs[0];
  }
  // prettier-ignore
  return funcs.reduce((a, b) => (value, ...rest) =>
    a(b(value, ...rest), ...rest));
};
