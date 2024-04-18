/**
 * Helps visualize highly complex ui data on the fly.
 * @example
 * ```tsx
 * const { data } = useBackend<CargoData>();
 * logger.log(shallowCopyWithTypes(data));
 * ```
 */
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
