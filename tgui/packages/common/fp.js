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
