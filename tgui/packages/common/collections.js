/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Converts a given collection to an array.
 *
 * - Arrays are returned unmodified;
 * - If object was provided, keys will be discarded;
 * - Everything else will result in an empty array.
 *
 * @returns {any[]}
 */
export const toArray = collection => {
  if (Array.isArray(collection)) {
    return collection;
  }
  if (typeof collection === 'object') {
    const hasOwnProperty = Object.prototype.hasOwnProperty;
    const result = [];
    for (let i in collection) {
      if (hasOwnProperty.call(collection, i)) {
        result.push(collection[i]);
      }
    }
    return result;
  }
  return [];
};

/**
 * Converts a given object to an array, and appends a key to every
 * object inside of that array.
 *
 * Example input (object):
 * ```
 * {
 *   'Foo': { info: 'Hello world!' },
 *   'Bar': { info: 'Hello world!' },
 * }
 * ```
 *
 * Example output (array):
 * ```
 * [
 *   { key: 'Foo', info: 'Hello world!' },
 *   { key: 'Bar', info: 'Hello world!' },
 * ]
 * ```
 *
 * @template T
 * @param {{ [key: string]: T }} obj Object, or in DM terms, an assoc array
 * @param {string} keyProp Property, to which key will be assigned
 * @returns {T[]} Array of keyed objects
 */
export const toKeyedArray = (obj, keyProp = 'key') => {
  return map((item, key) => ({
    [keyProp]: key,
    ...item,
  }))(obj);
};

/**
 * Iterates over elements of collection, returning an array of all elements
 * iteratee returns truthy for. The predicate is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 *
 * @returns {any[]}
 */
export const filter = iterateeFn => collection => {
  if (collection === null || collection === undefined) {
    return collection;
  }
  if (Array.isArray(collection)) {
    const result = [];
    for (let i = 0; i < collection.length; i++) {
      const item = collection[i];
      if (iterateeFn(item, i, collection)) {
        result.push(item);
      }
    }
    return result;
  }
  throw new Error(`filter() can't iterate on type ${typeof collection}`);
};

/**
 * Creates an array of values by running each element in collection
 * thru an iteratee function. The iteratee is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 *
 * @returns {any[]}
 */
export const map = iterateeFn => collection => {
  if (collection === null || collection === undefined) {
    return collection;
  }
  if (Array.isArray(collection)) {
    const result = [];
    for (let i = 0; i < collection.length; i++) {
      result.push(iterateeFn(collection[i], i, collection));
    }
    return result;
  }
  if (typeof collection === 'object') {
    const hasOwnProperty = Object.prototype.hasOwnProperty;
    const result = [];
    for (let i in collection) {
      if (hasOwnProperty.call(collection, i)) {
        result.push(iterateeFn(collection[i], i, collection));
      }
    }
    return result;
  }
  throw new Error(`map() can't iterate on type ${typeof collection}`);
};

const COMPARATOR = (objA, objB) => {
  const criteriaA = objA.criteria;
  const criteriaB = objB.criteria;
  const length = criteriaA.length;
  for (let i = 0; i < length; i++) {
    const a = criteriaA[i];
    const b = criteriaB[i];
    if (a < b) {
      return -1;
    }
    if (a > b) {
      return 1;
    }
  }
  return 0;
};

/**
 * Creates an array of elements, sorted in ascending order by the results
 * of running each element in a collection thru each iteratee.
 *
 * Iteratees are called with one argument (value).
 *
 * @returns {any[]}
 */
export const sortBy = (...iterateeFns) => array => {
  if (!Array.isArray(array)) {
    return array;
  }
  let length = array.length;
  // Iterate over the array to collect criteria to sort it by
  let mappedArray = [];
  for (let i = 0; i < length; i++) {
    const value = array[i];
    mappedArray.push({
      criteria: iterateeFns.map(fn => fn(value)),
      value,
    });
  }
  // Sort criteria using the base comparator
  mappedArray.sort(COMPARATOR);
  // Unwrap values
  while (length--) {
    mappedArray[length] = mappedArray[length].value;
  }
  return mappedArray;
};

export const sort = sortBy();

/**
 * A fast implementation of reduce.
 */
export const reduce = (reducerFn, initialValue) => array => {
  const length = array.length;
  let i;
  let result;
  if (initialValue === undefined) {
    i = 1;
    result = array[0];
  }
  else {
    i = 0;
    result = initialValue;
  }
  for (; i < length; i++) {
    result = reducerFn(result, array[i], i, array);
  }
  return result;
};

/**
 * Creates a duplicate-free version of an array, using SameValueZero for
 * equality comparisons, in which only the first occurrence of each element
 * is kept. The order of result values is determined by the order they occur
 * in the array.
 *
 * It accepts iteratee which is invoked for each element in array to generate
 * the criterion by which uniqueness is computed. The order of result values
 * is determined by the order they occur in the array. The iteratee is
 * invoked with one argument: value.
 */
export const uniqBy = iterateeFn => array => {
  const { length } = array;
  const result = [];
  const seen = iterateeFn ? [] : result;
  let index = -1;
  outer:
  while (++index < length) {
    let value = array[index];
    const computed = iterateeFn ? iterateeFn(value) : value;
    value = value !== 0 ? value : 0;
    if (computed === computed) {
      let seenIndex = seen.length;
      while (seenIndex--) {
        if (seen[seenIndex] === computed) {
          continue outer;
        }
      }
      if (iterateeFn) {
        seen.push(computed);
      }
      result.push(value);
    }
    else if (!seen.includes(computed)) {
      if (seen !== result) {
        seen.push(computed);
      }
      result.push(value);
    }
  }
  return result;
};

export const uniq = uniqBy();

/**
 * Creates an array of grouped elements, the first of which contains
 * the first elements of the given arrays, the second of which contains
 * the second elements of the given arrays, and so on.
 *
 * @returns {any[]}
 */
export const zip = (...arrays) => {
  if (arrays.length === 0) {
    return;
  }
  const numArrays = arrays.length;
  const numValues = arrays[0].length;
  const result = [];
  for (let valueIndex = 0; valueIndex < numValues; valueIndex++) {
    const entry = [];
    for (let arrayIndex = 0; arrayIndex < numArrays; arrayIndex++) {
      entry.push(arrays[arrayIndex][valueIndex]);
    }
    result.push(entry);
  }
  return result;
};

/**
 * This method is like "zip" except that it accepts iteratee to
 * specify how grouped values should be combined. The iteratee is
 * invoked with the elements of each group.
 *
 * @returns {any[]}
 */
export const zipWith = iterateeFn => (...arrays) => {
  return map(values => iterateeFn(...values))(zip(...arrays));
};
