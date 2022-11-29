// Does a deep merge of two objects. DO NOT FEED CIRCULAR OBJECTS
export const merge = (target, source) => {
  return Object.entries(source).reduce((newArray, [key, value]) => {
    newArray[key] =
      value && typeof value === 'object'
        ? merge(
          (newArray[key] = newArray[key] || (Array.isArray(value) ? [] : {})),
          value
        )
        : value;
    return newArray;
  }, target);
};
