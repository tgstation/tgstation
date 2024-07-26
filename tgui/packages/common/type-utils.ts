/**
 * Helps visualize highly complex ui data on the fly.
 * @example
 * ```tsx
 * const { data } = useBackend<CargoData>();
 * logger.log(getShallowTypes(data));
 * ```
 */
export function getShallowTypes(
  data: Record<string, any>,
): Record<string, any> {
  const output = {};

  for (const key in data) {
    if (Array.isArray(data[key])) {
      const arr: any[] = data[key];

      // Return the first array item if it exists
      if (data[key].length > 0) {
        output[key] = arr[0];
        continue;
      }

      output[key] = 'emptyarray';
    } else if (typeof data[key] === 'object' && data[key] !== null) {
      // Please inspect it further and make a new type for it
      output[key] = 'object (inspect) || Record<string, any>';
    } else if (typeof data[key] === 'number') {
      const num = Number(data[key]);

      // 0 and 1 could be booleans from byond
      if (num === 1 || num === 0) {
        output[key] = `${num}, BooleanLike?`;
        continue;
      }
      output[key] = data[key];
    }
  }

  return output;
}
