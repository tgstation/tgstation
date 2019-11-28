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
    return collection.map(iterateeFn);
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
 * A fast implementation of map.
 */
export const fastMap = (array, iterateeFn) => {
  const result = [];
  for (let i = 0; i < array.length; i++) {
    result.push(iterateeFn(array[i], i));
  }
  return result;
};

/**
 * A version of fastMap, but for mapping over two arrays instead of one.
 */
export const fastProduct = (arrayA, arrayB, iterateeFn) => {
  const result = [];
  for (let i = 0; i < arrayA.length; i++) {
    result.push(iterateeFn(arrayA[i], arrayB[i], i));
  }
  return result;
};

/**
 * A fast implementation of reduce.
 */
export const fastReduce = (array, reducerFn, initialValue) => {
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
