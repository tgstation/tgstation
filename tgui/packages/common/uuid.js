/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Creates a UUID v4 string
 *
 * @return {string}
 */
export const createUuid = () => {
  let d = new Date().getTime();
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (d + Math.random() * 16) % 16 | 0;
    d = Math.floor(d / 16);
    // prettier-ignore
    return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  });
};
