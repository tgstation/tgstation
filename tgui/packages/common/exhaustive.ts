/**
 * Throws an error such that a non-exhaustive check will error at compile time
 * when using TypeScript, rather than at runtime.
 *
 * For example:
 * enum Color { Red, Green, Blue }
 * switch (color) {
 *  case Color.Red:
 *    return "red";
 *  case Color.Green:
 *    return "green";
 *  default:
 *    // This will error at compile time that we forgot blue.
 *    exhaustiveCheck(color);
 * }
 */
export const exhaustiveCheck = (input: never) => {
  throw new Error(`Unhandled case: ${input}`);
};
