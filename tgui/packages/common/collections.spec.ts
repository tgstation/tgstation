import { zip } from "./collections";

// Type assertions, these will lint if the types are wrong.
const _zip1: [string, number] = zip(["a"], [1])[0];

describe("zip", () => {
  test("zip(['a', 'b', 'c'], [1, 2, 3, 4])", () => {
    expect(zip(["a", "b", "c"], [1, 2, 3, 4])).toEqual([
      ["a", 1],
      ["b", 2],
      ["c", 3],
    ]);
  });
});
