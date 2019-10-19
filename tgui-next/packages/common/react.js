/**
 * Helper for conditionally adding/removing classes in React
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

/**
 * Normalizes children prop, so that it is always an array of VDom
 * elements.
 */
export const normalizeChildren = children => {
  if (Array.isArray(children)) {
    return children.filter(value => value);
  }
  if (typeof children === 'object') {
    return [children];
  }
  return [];
};

/**
 * Shallowly checks if two objects are different.
 * Credit: https://github.com/developit/preact-compat
 */
export const shallowDiffers = (a, b) => {
  let i;
  for (i in a) {
    if (!(i in b)) {
      return true;
    }
  }
  for (i in b) {
    if (a[i] !== b[i]) {
      return true;
    }
  }
  return false;
};

/**
 * Default inferno hooks for pure components.
 */
export const pureComponentHooks = {
  onComponentShouldUpdate: (lastProps, nextProps) => {
    return shallowDiffers(lastProps, nextProps);
  },
};

/**
 * A helper to determine whether to render an item.
 */
export const isFalsy = value => {
  return value === undefined
    || value === null
    || value === false;
};
