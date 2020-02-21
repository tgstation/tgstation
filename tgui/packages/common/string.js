/**
 * Removes excess whitespace and indentation from the string.
 */
export const multiline = str => {
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

/**
 * Matches strings with wildcards.
 * Example: testGlobPattern('*@domain')('user@domain') === true
 */
export const testGlobPattern = pattern => {
  const escapeString = str => str.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&');
  const regex = new RegExp('^'
    + pattern.split(/\*+/).map(escapeString).join('.*')
    + '$');
  return str => regex.test(str);
};

export const capitalize = str => {
  // Handle array
  if (Array.isArray(str)) {
    return str.map(capitalize);
  }
  // Handle string
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
};

export const toTitleCase = str => {
  // Handle array
  if (Array.isArray(str)) {
    return str.map(toTitleCase);
  }
  // Pass non-string
  if (typeof str !== 'string') {
    return str;
  }
  // Handle string
  const WORDS_UPPER = ['Id', 'Tv'];
  const WORDS_LOWER = [
    'A', 'An', 'And', 'As', 'At', 'But', 'By', 'For', 'For', 'From', 'In',
    'Into', 'Near', 'Nor', 'Of', 'On', 'Onto', 'Or', 'The', 'To', 'With',
  ];
  let currentStr = str.replace(/([^\W_]+[^\s-]*) */g, str => {
    return str.charAt(0).toUpperCase() + str.substr(1).toLowerCase();
  });
  for (let word of WORDS_LOWER) {
    const regex = new RegExp('\\s' + word + '\\s', 'g');
    currentStr = currentStr.replace(regex, str => str.toLowerCase());
  }
  for (let word of WORDS_UPPER) {
    const regex = new RegExp('\\b' + word + '\\b', 'g');
    currentStr = currentStr.replace(regex, str => str.toLowerCase());
  }
  return currentStr;
};

/**
 * Decodes HTML entities, and removes unnecessary HTML tags.
 *
 * @param  {String} str Encoded HTML string
 * @return {String} Decoded HTML string
 */
export const decodeHtmlEntities = str => {
  if (!str) {
    return str;
  }
  const translate_re = /&(nbsp|amp|quot|lt|gt|apos);/g;
  const translate = {
    nbsp: ' ',
    amp: '&',
    quot: '"',
    lt: '<',
    gt: '>',
    apos: '\'',
  };
  return str
    // Newline tags
    .replace(/<br>/gi, '\n')
    .replace(/<\/?[a-z0-9-_]+[^>]*>/gi, '')
    // Basic entities
    .replace(translate_re, (match, entity) => translate[entity])
    // Decimal entities
    .replace(/&#?([0-9]+);/gi, (match, numStr) => {
      const num = parseInt(numStr, 10);
      return String.fromCharCode(num);
    })
    // Hex entities
    .replace(/&#x?([0-9a-f]+);/gi, (match, numStr) => {
      const num = parseInt(numStr, 16);
      return String.fromCharCode(num);
    });
};

/**
 * Converts an object into a query string,
 */
export const buildQueryString = obj => Object.keys(obj)
  .map(key => encodeURIComponent(key)
    + '=' + encodeURIComponent(obj[key]))
  .join('&');
