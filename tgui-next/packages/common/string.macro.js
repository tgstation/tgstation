const { createMacro } = require('babel-plugin-macros');

/**
 * Removes excess whitespace and indentation from the string.
 *
 * This function is not called directly in runtime, but instead is called
 * by the macro, which is defined below, and it runs at compile time.
 */
const multiline = str => {
  if (Array.isArray(str)) {
    // Small stub to allow usage as a template tag
    return multiline(str.join(''));
  }
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

module.exports = createMacro(args => {
  const { references, state, babel } = args;
  const t = babel.types;
  const multilinePaths = references.multiline || [];

  multilinePaths.forEach(path => {
    if (path.container.type === 'TaggedTemplateExpression') {
      const { quasi } = path.container;
      if (quasi.expressions.length > 0) {
        throw new Error('Multiline tag does not support expressions!');
      }
      if (quasi.quasis.length > 1) {
        throw new Error('Quasis is longer than 1');
      }
      const { value } = quasi.quasis[0];
      value.raw = multiline(value.raw);
      value.cooked = multiline(value.cooked);
      path.parentPath.replaceWith(quasi);
    }
  });
});
