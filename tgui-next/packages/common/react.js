/**
 * Helper for conditionally adding/removing classes in React
 *
 * @copyright 2018 Aleksej Komarov
 * @license GPL-2.0-or-later
 *
 * @return {string}
 */
export const classes = (...args) => {
  const classNames = [];
  const hasOwn = Object.prototype.hasOwnProperty;
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (!arg) {
      continue;
    }
    if (typeof arg === 'string' || typeof arg === 'number') {
      classNames.push(arg);
    }
    else if (Array.isArray(arg) && arg.length) {
      const inner = classes.apply(null, arg);
      if (inner) {
        classNames.push(inner);
      }
    }
    else if (typeof arg === 'object') {
      for (let key in arg) {
        if (hasOwn.call(arg, key) && arg[key]) {
          classNames.push(key);
        }
      }
    }
  }
  return classNames.join(' ');
};
