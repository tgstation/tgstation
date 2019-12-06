import { map, product, reduce } from './collections';

/**
 * Creates a vector, with as many dimensions are there are arguments.
 */
export const vec = (...components) => {
  if (Array.isArray(components[0])) {
    return new Vector(components[0]);
  }
  return new Vector(components);
};

const ADD = (a, b) => a + b;
const SUB = (a, b) => a - b;
const MUL = (a, b) => a * b;

class Vector {
  constructor(components) {
    this.c = components;
  }

  add(vec) {
    return new Vector(product(ADD)(this.c, vec.c));
  }

  subtract(vec) {
    return new Vector(product(SUB)(this.c, vec.c));
  }

  multiply(n) {
    return new Vector(map(x => x * n)(this.c));
  }

  divide(n) {
    return new Vector(map(x => x / n)(this.c));
  }

  magnitude() {
    return Math.sqrt(reduce(ADD)(product(MUL)(this.c, this.c)));
  }

  normalize() {
    return this.divide(this.magnitude());
  }
}
