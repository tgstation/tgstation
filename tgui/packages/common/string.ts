/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Creates a search terms matcher. Returns true if given string matches the search text.
 *
 * @example
 * ```tsx
 * type Thing = { id: string; name: string };
 *
 * const objects = [
 *   { id: '123', name: 'Test' },
 *   { id: '456', name: 'Test' },
 * ];
 *
 * const search = createSearch('123', (obj: Thing) => obj.id);
 *
 * objects.filter(search); // returns [{ id: '123', name: 'Test' }]
 * ```
 */
export function createSearch<TObj>(
  searchText: string,
  stringifier = (obj: TObj) => JSON.stringify(obj),
): (obj: TObj) => boolean {
  const preparedSearchText = searchText.toLowerCase().trim();

  return (obj) => {
    if (!preparedSearchText) {
      return true;
    }
    const str = stringifier(obj);
    if (!str) {
      return false;
    }
    return str.toLowerCase().includes(preparedSearchText);
  };
}

/**
 * Capitalizes a word and lowercases the rest.
 *
 * @example
 * ```tsx
 * capitalize('heLLo') // Hello
 * ```
 */
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

/**
 * Similar to capitalize, this takes a string and replaces all first letters
 * of any words.
 *
 * @example
 * ```tsx
 * capitalizeAll('heLLo woRLd') // 'HeLLo WoRLd'
 * ```
 */
export function capitalizeAll(str: string): string {
  return str.replace(/(^\w{1})|(\s+\w{1})/g, (letter) => letter.toUpperCase());
}

/**
 * Capitalizes only the first letter of the str, leaving others untouched.
 *
 * @example
 * ```tsx
 * capitalizeFirst('heLLo woRLd') // 'HeLLo woRLd'
 * ```
 */
export function capitalizeFirst(str: string): string {
  return str.replace(/^\w/, (letter) => letter.toUpperCase());
}

const WORDS_UPPER = ['Id', 'Tv'] as const;

const WORDS_LOWER = [
  'A',
  'An',
  'And',
  'As',
  'At',
  'But',
  'By',
  'For',
  'For',
  'From',
  'In',
  'Into',
  'Near',
  'Nor',
  'Of',
  'On',
  'Onto',
  'Or',
  'The',
  'To',
  'With',
] as const;

/**
 * Converts a string to title case.
 *
 * @example
 * ```tsx
 * toTitleCase('a tale of two cities') // 'A Tale of Two Cities'
 * ```
 */
export function toTitleCase(str: string): string {
  if (!str) return str;

  let currentStr = str.replace(/([^\W_]+[^\s-]*) */g, (str) => {
    return capitalize(str);
  });

  for (let word of WORDS_LOWER) {
    const regex = new RegExp('\\s' + word + '\\s', 'g');
    currentStr = currentStr.replace(regex, (str) => str.toLowerCase());
  }

  for (let word of WORDS_UPPER) {
    const regex = new RegExp('\\b' + word + '\\b', 'g');
    currentStr = currentStr.replace(regex, (str) => str.toLowerCase());
  }

  return currentStr;
}

const TRANSLATE_REGEX = /&(nbsp|amp|quot|lt|gt|apos);/g;
const TRANSLATIONS = {
  amp: '&',
  apos: "'",
  gt: '>',
  lt: '<',
  nbsp: ' ',
  quot: '"',
} as const;

/**
 * Decodes HTML entities and removes unnecessary HTML tags.
 *
 * @example
 * ```tsx
 * decodeHtmlEntities('&amp;') // returns '&'
 * decodeHtmlEntities('&lt;') // returns '<'
 * ```
 */
export function decodeHtmlEntities(str: string): string {
  if (!str) return str;

  return (
    str
      // Newline tags
      .replace(/<br>/gi, '\n')
      .replace(/<\/?[a-z0-9-_]+[^>]*>/gi, '')
      // Basic entities
      .replace(TRANSLATE_REGEX, (match, entity) => TRANSLATIONS[entity])
      // Decimal entities
      .replace(/&#?([0-9]+);/gi, (match, numStr) => {
        const num = parseInt(numStr, 10);
        return String.fromCharCode(num);
      })
      // Hex entities
      .replace(/&#x?([0-9a-f]+);/gi, (match, numStr) => {
        const num = parseInt(numStr, 16);
        return String.fromCharCode(num);
      })
  );
}
