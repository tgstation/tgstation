/**
 * Returns the arguments of a function F as an array.
 */
export type ArgumentsOf<F extends Function>
  = F extends (...args: infer A) => unknown ? A : never;
