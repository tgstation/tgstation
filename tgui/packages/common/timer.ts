/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Returns a function, that, as long as it continues to be invoked, will
 * not be triggered. The function will be called after it stops being
 * called for N milliseconds. If `immediate` is passed, trigger the
 * function on the leading edge, instead of the trailing.
 */
export const debounce = <F extends (...args: any[]) => any>(
  fn: F,
  time: number,
  immediate = false
): ((...args: Parameters<F>) => void) => {
  let timeout: ReturnType<typeof setTimeout> | null;
  return (...args: Parameters<F>) => {
    const later = () => {
      timeout = null;
      if (!immediate) {
        fn(...args);
      }
    };
    const callNow = immediate && !timeout;
    clearTimeout(timeout!);
    timeout = setTimeout(later, time);
    if (callNow) {
      fn(...args);
    }
  };
};

/**
 * Returns a function, that, when invoked, will only be triggered at most once
 * during a given window of time.
 */
export const throttle = <F extends (...args: any[]) => any>(
  fn: F,
  time: number
): ((...args: Parameters<F>) => void) => {
  let previouslyRun: number | null,
    queuedToRun: ReturnType<typeof setTimeout> | null;
  return function invokeFn(...args: Parameters<F>) {
    const now = Date.now();
    if (queuedToRun) {
      clearTimeout(queuedToRun);
    }
    if (!previouslyRun || now - previouslyRun >= time) {
      fn.apply(null, args);
      previouslyRun = now;
    } else {
      queuedToRun = setTimeout(
        () => invokeFn(...args),
        time - (now - (previouslyRun ?? 0))
      );
    }
  };
};

/**
 * Suspends an asynchronous function for N milliseconds.
 *
 * @param {number} time
 */
export const sleep = (time: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, time));
