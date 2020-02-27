/**
 * Helper for conditionally adding/removing classes in React
 *
 * @param {any[]} classNames
 * @return {string}
 */
export const classes = classNames => {
  let className = '';
  for (let i = 0; i < classNames.length; i++) {
    const part = classNames[i];
    if (typeof part === 'string') {
      className += part + ' ';
    }
  }
  return className;
};

/**
 * Normalizes children prop, so that it is always an array of VDom
 * elements.
 */
export const normalizeChildren = children => {
  if (Array.isArray(children)) {
    return children.flat().filter(value => value);
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
