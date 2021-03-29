/**
 * Uses DOMPurify to purify/sanitise HTML.
 */

import DOMPurify from 'dompurify';

// Default values
let defTag = [
  'b',
  'br',
  'center',
  'code',
  'div',
  'font',
  'hr',
  'i',
  'li',
  'menu',
  'ol',
  'p',
  'pre',
  'span',
  'table',
  'td',
  'th',
  'tr',
  'u',
  'ul',
];
let defAttr = ['class', 'style'];

/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param {string} input
 * @param {array} tags
 * @param {array} forbidAttr
 */
export const sanitizeText = (input, tags = defTag, forbidAttr = defAttr) => {
  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it dosn't
  // kill href links or such
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: tags,
    FORBID_ATTR: forbidAttr,
  });
};
