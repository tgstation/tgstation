/**
 * Returns the arguments of a function F as an array.
 */
export type ArgumentsOf<F extends Function> =
	// eslint-disable-next-line no-unused-vars
	F extends (...args: infer A) => unknown ? A : never;
