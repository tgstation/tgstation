/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Highlights the text in the node based on the provided regular expression.
 *
 * @param {Node} node Node which you want to process
 * @param {RegExp} regex Regular expression to highlight
 * @param {(text: string) => Node} creator Highlight node creator
 * @returns {number} Number of matches
 */
export const highlightNode = (node, regex, creator) => {
  let n = 0;
  const childNodes = node.childNodes;
  for (let node of childNodes) {
    if (node.nodeType === 3) {
      n += highlightTextNode(node, regex, creator);
    }
    else {
      n += highlightNode(node, regex, creator);
    }
  }
  return n;
};

const highlightTextNode = (node, regex, creator) => {
  const text = node.textContent;
  const textLength = text.length;
  let match;
  let lastIndex = 0;
  let fragment;
  let n = 0;
  // eslint-disable-next-line no-cond-assign
  while (match = regex.exec(text)) {
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
      fragment.appendChild(document.createTextNode(
        text.substring(lastIndex, matchIndex)));
    }
    lastIndex = matchIndex + matchLength;
    // Create a highlight node
    if (creator) {
      fragment.appendChild(creator(matchText));
    }
    else {
      const highlightNode = document.createElement('span');
      highlightNode.setAttribute('style',
        'background-color:#fd4;color:#000');
      highlightNode.textContent = matchText;
      fragment.appendChild(highlightNode);
    }
  }
  if (fragment) {
    // Insert the remaining unmatched chunk
    if (lastIndex < textLength) {
      fragment.appendChild(document.createTextNode(
        text.substring(lastIndex, textLength)));
    }
    // Commit the fragment
    node.parentNode.replaceChild(fragment, node);
  }
  return n;
};
