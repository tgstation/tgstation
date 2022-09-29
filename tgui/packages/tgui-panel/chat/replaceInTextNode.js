/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Replaces text matching a regular expression with a custom node.
 */
export const replaceInTextNode = (regex, createNode) => (node) => {
  const text = node.textContent;
  const textLength = text.length;
  let match;
  let lastIndex = 0;
  let fragment;
  let n = 0;
  // eslint-disable-next-line no-cond-assign
  while ((match = regex.exec(text))) {
    n += 1;
    // Lazy init fragment
    if (!fragment) {
      fragment = document.createDocumentFragment();
    }
    const matchText = match[0];
    const matchLength = matchText.length;
    const matchIndex = match.index;
    // Insert previous unmatched chunk
    if (lastIndex < matchIndex) {
      fragment.appendChild(
        document.createTextNode(text.substring(lastIndex, matchIndex))
      );
    }
    lastIndex = matchIndex + matchLength;
    // Create a wrapper node
    fragment.appendChild(createNode(matchText));
  }
  if (fragment) {
    // Insert the remaining unmatched chunk
    if (lastIndex < textLength) {
      fragment.appendChild(
        document.createTextNode(text.substring(lastIndex, textLength))
      );
    }
    // Commit the fragment
    node.parentNode.replaceChild(fragment, node);
  }
  return n;
};

// Highlight
// --------------------------------------------------------

/**
 * Default highlight node.
 */
const createHighlightNode = (text) => {
  const node = document.createElement('span');
  node.setAttribute('style', 'background-color:#fd4;color:#000');
  node.textContent = text;
  return node;
};

/**
 * Highlights the text in the node based on the provided regular expression.
 *
 * @param {Node} node Node which you want to process
 * @param {RegExp} regex Regular expression to highlight
 * @param {(text: string) => Node} createNode Highlight node creator
 * @returns {number} Number of matches
 */
export const highlightNode = (
  node,
  regex,
  createNode = createHighlightNode
) => {
  if (!createNode) {
    createNode = createHighlightNode;
  }
  let n = 0;
  const childNodes = node.childNodes;
  for (let i = 0; i < childNodes.length; i++) {
    const node = childNodes[i];
    // Is a text node
    if (node.nodeType === 3) {
      n += replaceInTextNode(regex, createNode)(node);
    } else {
      n += highlightNode(node, regex, createNode);
    }
  }
  return n;
};

// Linkify
// --------------------------------------------------------

// prettier-ignore
const URL_REGEX = /(?:(?:https?:\/\/)|(?:www\.))(?:[^ ]*?\.[^ ]*?)+[-A-Za-z0-9+&@#/%?=~_|$!:,.;()]+/ig;

/**
 * Highlights the text in the node based on the provided regular expression.
 *
 * @param {Node} node Node which you want to process
 * @returns {number} Number of matches
 */
export const linkifyNode = (node) => {
  let n = 0;
  const childNodes = node.childNodes;
  for (let i = 0; i < childNodes.length; i++) {
    const node = childNodes[i];
    const tag = String(node.nodeName).toLowerCase();
    // Is a text node
    if (node.nodeType === 3) {
      n += linkifyTextNode(node);
    } else if (tag !== 'a') {
      n += linkifyNode(node);
    }
  }
  return n;
};

const linkifyTextNode = replaceInTextNode(URL_REGEX, (text) => {
  const node = document.createElement('a');
  node.href = text;
  node.textContent = text;
  return node;
});
