/**
 * Returns the arguments of a function F as an array.
 */
export type ArgumentTypes<F extends Function>
  = F extends (...args: infer A) => unknown ? A : never;
