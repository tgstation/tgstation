import { fastMap, fastProduct, fastReduce } from './collections';

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
    return new Vector(fastProduct(this.c, vec.c, ADD));
  }

  subtract(vec) {
    return new Vector(fastProduct(this.c, vec.c, SUB));
  }

  multiply(n) {
    return new Vector(fastMap(this.c, x => x * n));
  }

  divide(n) {
    return new Vector(fastMap(this.c, x => x / n));
  }

  magnitude() {
    return Math.sqrt(fastReduce(fastProduct(this.c, this.c, MUL), ADD));
  }

  normalize() {
    return this.divide(this.magnitude());
  }
}
