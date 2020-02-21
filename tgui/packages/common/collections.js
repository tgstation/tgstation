/**
 * Converts a given collection to an array.
 *
 * - Arrays are returned unmodified;
 * - If object was provided, keys will be discarded;
 * - Everything else will result in an empty array.
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
 * Creates an array of values by running each element in collection
 * thru an iteratee function. The iteratee is invoked with three
 * arguments: (value, index|key, collection).
 *
 * If collection is 'null' or 'undefined', it will be returned "as is"
 * without emitting any errors (which can be useful in some cases).
 */
export const map = iterateeFn => collection => {
  if (collection === null && collection === undefined) {
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
 * Creates an array of grouped elements, the first of which contains
 * the first elements of the given arrays, the second of which contains
 * the second elements of the given arrays, and so on.
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
 */
export const zipWith = iterateeFn => (...arrays) => {
  return map(values => iterateeFn(...values))(zip(...arrays));
};
