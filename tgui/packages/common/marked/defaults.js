/**
 * @copyright 2011-2020
 * @author Original Author Christopher Jeffrey (https://github.com/chjj/)
 * @author Changes Author WarlockD (https://github.com/warlockd)
 * @license MIT
 */

export const getDefaults = () => {
  return {
    baseUrl: null,
    breaks: false,
    gfm: true,
    headerIds: true,
    headerPrefix: '',
    highlight: null,
    langPrefix: 'language-',
    mangle: true,
    pedantic: false,
    renderer: null,
    sanitize: false,
    sanitizer: null,
    silent: false,
    smartLists: false,
    smartypants: false,
    tokenizer: null,
    xhtml: false,
  };
};

export const defaults = getDefaults();
