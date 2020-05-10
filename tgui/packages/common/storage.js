/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const STORAGE_NONE = 0;
export const STORAGE_LOCAL_STORAGE = 1;
export const STORAGE_INDEXED_DB = 2;

const createMock = () => {
  let storage = {};
  const get = key => storage[key];
  const set = (key, value) => {
    storage[key] = value;
  };
  const remove = key => {
    storage[key] = undefined;
  };
  const clear = () => {
    // NOTE: On IE8, this will probably leak memory if used often.
    storage = {};
  };
  return {
    get,
    set,
    remove,
    clear,
    engine: STORAGE_NONE,
  };
};

const createLocalStorage = () => {
  const get = key => {
    const value = localStorage.getItem(key);
    if (typeof value !== 'string') {
      return;
    }
    return JSON.parse(value);
  };
  const set = (key, value) => {
    localStorage.setItem(key, JSON.stringify(value));
  };
  const remove = key => {
    localStorage.removeItem(key);
  };
  const clear = () => {
    localStorage.clear();
  };
  return {
    get,
    set,
    remove,
    clear,
    engine: STORAGE_LOCAL_STORAGE,
  };
};

export const storage = (
  window.localStorage && createLocalStorage()
  || createMock()
);
