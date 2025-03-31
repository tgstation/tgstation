/**
 * Uses DOMPurify to purify/sanitise HTML.
 */

import DOMPurify from 'dompurify';

// Default values
const defTag = [
  'b',
  'blockquote',
  'br',
  'center',
  'code',
  'dd',
  'del',
  'div',
  'dl',
  'dt',
  'em',
  'font',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'hr',
  'i',
  'ins',
  'li',
  'menu',
  'ol',
  'p',
  'pre',
  'span',
  'strong',
  'table',
  'tbody',
  'td',
  'th',
  'thead',
  'tfoot',
  'tr',
  'u',
  'ul',
];

// Advanced HTML tags that we can trust admins (but not players) with
const advTag = ['img'];

// Background is here because it accepts image urls
const defAttr = ['class', 'style', 'background'];

/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param input - Input HTML string to sanitize
 * @param advHtml - Flag to enable/disable advanced HTML
 * @param tags - List of allowed HTML tags
 * @param forbidAttr - List of forbidden HTML attributes
 * @param advTags - List of advanced HTML tags allowed for trusted sources
 */
export const sanitizeText = (
  input: string,
  advHtml = false,
  tags = defTag,
  forbidAttr = defAttr,
  advTags = advTag,
) => {
  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it doesn't
  // kill href links or such
  if (advHtml) {
    tags = tags.concat(advTags);
  }
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: tags,
    FORBID_ATTR: forbidAttr,
  });
};
