/**
 * @copyright 2011-2020
 * @author Original Author Christopher Jeffrey (https://github.com/chjj/)
 * @author Changes Author WarlockD (https://github.com/warlockd)
 * @license MIT
 */


/**
 * Slugger generates header id
 */
export class Slugger {
  constructor() {
    this.seen = {};
  }

  /**
   * Convert string to unique id
   */
  slug(value) {
    let slug = value
      .toLowerCase()
      .trim()
      // remove html tags
      .replace(/<[!/a-z].*?>/ig, '')
      // remove unwanted chars
      .replace(/[\u2000-\u206F\u2E00-\u2E7F\\'!"#$%&()*+,./:;<=>?@[\]^`{|}~]/g, '')
      .replace(/\s/g, '-');

    if (Object.prototype.hasOwnProperty.call(this.seen, slug)) {
      const originalSlug = slug;
      do {
        this.seen[originalSlug]++;
        slug = originalSlug + '-' + this.seen[originalSlug];
      } while (Object.prototype.hasOwnProperty.call(this.seen, slug));
    }
    this.seen[slug] = 0;

    return slug;
  }
}
