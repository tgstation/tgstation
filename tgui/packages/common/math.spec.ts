import { range } from "./math";

describe("range", () => {
  test("range(0, 5)", () => {
    expect(range(0, 5)).toEqual([0, 1, 2, 3, 4]);
  });
});
