/**
 * This plugin saves overall about 10KB on the final bundle size, so it's
 * sort of worth it.
 *
 * We are using a .cjs extension because:
 *
 * 1. Webpack CLI only supports CommonJS modules;
 * 2. tgui-dev-server supports both, but we still need to signal NodeJS
 * to import it as a CommonJS module, hence .cjs extension.
 *
 * We need to copy-paste the whole "multiline" function because we can't
 * synchronously import an ES module from a CommonJS module.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Removes excess whitespace and indentation from the string.
 */
const multiline = str => {
  const lines = str.split('\n');
  // Determine base indentation
  let minIndent;
  for (let line of lines) {
    for (let indent = 0; indent < line.length; indent++) {
      const char = line[indent];
      if (char !== ' ') {
        if (minIndent === undefined || indent < minIndent) {
          minIndent = indent;
        }
        break;
      }
    }
  }
  if (!minIndent) {
    minIndent = 0;
  }
  // Remove this base indentation and trim the resulting string
  // from both ends.
  return lines
    .map(line => line.substr(minIndent).trimRight())
    .join('\n')
    .trim();
};

const StringPlugin = ref => {
  return {
    visitor: {
      TaggedTemplateExpression: path => {
        if (path.node.tag.name === 'multiline') {
          const { quasi } = path.node;
          if (quasi.expressions.length > 0) {
            throw new Error('Multiline tag does not support expressions!');
          }
          if (quasi.quasis.length > 1) {
            throw new Error('Quasis is longer than 1');
          }
          const { value } = quasi.quasis[0];
          value.raw = multiline(value.raw);
          value.cooked = multiline(value.cooked);
          path.replaceWith(quasi);
        }
      },
    },
  };
};

module.exports = {
  __esModule: true,
  default: StringPlugin,
};
