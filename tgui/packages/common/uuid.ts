/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Creates a UUID v4 string
 *
 * @example
 * ```tsx
 * createUuid(); // 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
 * ```
 */
export function createUuid(): string {
  let d = new Date().getTime();

  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (d + Math.random() * 16) % 16 | 0;
    d = Math.floor(d / 16);

    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
  });
}
