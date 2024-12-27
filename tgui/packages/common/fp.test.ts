import { flow } from './fp';

describe('flow', () => {
  it('composes multiple functions into one', () => {
    const add2 = (x) => x + 2;
    const multiplyBy3 = (x) => x * 3;
    const subtract5 = (x) => x - 5;

    const composedFunction = flow(add2, multiplyBy3, subtract5);

    expect(composedFunction(4)).toBe(13); // ((4 + 2) * 3) - 5 = 13
  });

  it('handles arrays of functions', () => {
    const add2 = (x) => x + 2;
    const multiplyBy3 = (x) => x * 3;
    const subtract5 = (x) => x - 5;

    const composedFunction = flow([add2, multiplyBy3], subtract5);

    expect(composedFunction(4)).toBe(13); // ((4 + 2) * 3) - 5 = 13
  });
});
