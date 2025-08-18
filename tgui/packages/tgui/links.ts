/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Prevents baby jailing the user when he clicks an external link.
 */
export const captureExternalLinks = () => {
  // Subscribe to all document clicks
  document.addEventListener('click', (evt: MouseEvent) => {
    let target = evt.target as HTMLElement;
    // Recurse down the tree to find a valid link
    while (true) {
      // Reached the end, bail.
      if (!target || target === document.body) {
        return;
      }
      const tagName = String(target.tagName).toLowerCase();
      if (tagName === 'a') {
        break;
      }
      target = target.parentElement as HTMLElement;
    }
    const hrefAttr = target.getAttribute('href') || '';
    // Leave BYOND links alone
    const isByondLink =
      hrefAttr.charAt(0) === '?' || hrefAttr.startsWith('byond://');
    if (isByondLink) {
      return;
    }
    // Prevent default action
    evt.preventDefault();
    // Normalize the URL
    let url = hrefAttr;
    if (url.toLowerCase().startsWith('www')) {
      url = `https://${url}`;
    }
    // Open the link
    Byond.sendMessage({
      type: 'openLink',
      url,
    });
  });
};
