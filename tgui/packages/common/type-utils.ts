/** Type data grabber for very complex ui data. */
export function shallowCopyWithTypes(
  data: Record<string, any>,
): Record<string, any> {
  const output = {};

  for (const key in data) {
    if (Array.isArray(data[key])) {
      output[key] = 'array';
    } else if (typeof data[key] === 'object' && data[key] !== null) {
      output[key] = 'obj';
    } else {
      output[key] = data[key];
    }
  }

  return output;
}
