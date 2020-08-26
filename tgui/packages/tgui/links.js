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
  document.addEventListener('click', e => {
    const tagName = String(e.target.tagName).toLowerCase();
    const hrefAttr = e.target.getAttribute('href') || '';
    // Must be a link
    if (tagName !== 'a') {
      return;
    }
    // Leave BYOND links alone
    const isByondLink = hrefAttr.charAt(0) === '?'
      || hrefAttr.startsWith('byond://');
    if (isByondLink) {
      return;
    }
    // Prevent default action
    e.preventDefault();
    // Normalize the URL
    let url = hrefAttr;
    if (url.toLowerCase().startsWith('www')) {
      url = 'https://' + url;
    }
    // Open the link
    Byond.topic({
      tgui: 1,
      window_id: window.__windowId__,
      type: 'openLink',
      url,
    });
  });
};
