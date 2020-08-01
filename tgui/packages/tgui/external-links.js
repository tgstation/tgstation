/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { sendMessage } from './backend';

/**
 * Prevents baby jailing the user when he clicks an external link.
 */
export const setupExternalLinkCapturing = () => {
  // Click handler
  const listenerFn = e => {
    const tagName = String(e.target.tagName).toLowerCase();
    const href = String(e.target.href);
    // Must be a link
    if (tagName !== 'a') {
      return;
    }
    // Leave BYOND links alone
    const isByondLink = href.charAt(0) === '?'
      || href.startsWith(location.origin)
      || href.startsWith('byond://');
    if (isByondLink) {
      return;
    }
    // Prevent default action
    e.preventDefault();
    // Send a message to open this external link in default system browser.
    sendMessage({
      type: 'openLink',
      payload: {
        url: href,
      },
    });
  };
  // Subscribe to all document clicks
  document.addEventListener('click', listenerFn);
};
