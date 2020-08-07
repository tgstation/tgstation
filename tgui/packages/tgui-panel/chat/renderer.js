/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { EventEmitter } from 'common/events';
import { classes } from 'common/react';
import { createLogger } from 'tgui/logging';
import { COMBINE_MAX_MESSAGES, COMBINE_MAX_TIME_WINDOW, DEFAULT_PAGE, MAX_PERSISTED_MESSAGES, MAX_VISIBLE_MESSAGES, MESSAGE_PRUNE_INTERVAL, MESSAGE_TYPES, IMAGE_RETRY_DELAY, IMAGE_RETRY_LIMIT, IMAGE_RETRY_MESSAGE_AGE } from './constants';
import { highlightNode } from './highlight';
import { canPageAcceptType } from './selectors';

const logger = createLogger('chatRenderer');

// We consider this as the smallest possible scroll offset
// that is still trackable.
const SCROLL_TRACKING_TOLERANCE = 24;

const findNearestScrollableParent = startingNode => {
  const body = document.body;
  let node = startingNode;
  while (node && node !== body) {
    // This definitely has a vertical scrollbar, because it reduces
    // scrollWidth of the element. Might not work if element uses
    // overflow: hidden.
    if (node.scrollWidth < node.offsetWidth) {
      return node;
    }
    node = node.parentNode;
  }
  return window;
};

export const createMessage = payload => ({
  createdAt: Date.now(),
  ...payload,
});

export const serializeMessage = message => ({
  type: message.type,
  text: message.text,
  times: message.times,
  createdAt: message.createdAt,
});

const createHighlightNode = (text, color) => {
  const node = document.createElement('span');
  node.className = 'Chat__highlight';
  node.setAttribute('style', 'background-color:' + color);
  node.textContent = text;
  return node;
};

const createMessageNode = () => {
  const node = document.createElement('div');
  node.className = 'ChatMessage';
  return node;
};

const createReconnectedNode = () => {
  const node = document.createElement('div');
  node.className = 'Chat__reconnected';
  return node;
};

const handleImageError = e => {
  setTimeout(() => {
    /** @type {HTMLImageElement} */
    const node = e.target;
    const attempts = parseInt(node.getAttribute('data-reload-n'), 10) || 0;
    if (attempts >= IMAGE_RETRY_LIMIT) {
      logger.error(`failed to load an image after ${attempts} attempts`);
      return;
    }
    const src = node.src;
    node.src = null;
    node.src = src + '#' + attempts;
    node.setAttribute('data-reload-n', attempts + 1);
  }, IMAGE_RETRY_DELAY);
};

/**
 * Assigns a "times-repeated" badge to the message.
 */
const updateMessageBadge = message => {
  const { node, times } = message;
  if (!node || !times) {
    // Nothing to update
    return;
  }
  const foundBadge = node.querySelector('.Chat__badge');
  const badge = foundBadge || document.createElement('div');
  badge.textContent = times;
  badge.className = classes([
    'Chat__badge',
    'Chat__badge--animate',
  ]);
  requestAnimationFrame(() => {
    badge.className = 'Chat__badge';
  });
  if (!foundBadge) {
    node.appendChild(badge);
  }
};

class ChatRenderer {
  constructor() {
    /** @type {HTMLElement} */
    this.rootNode = null;
    this.queue = [];
    this.messages = [];
    this.visibleMessages = [];
    this.page = DEFAULT_PAGE;
    this.events = new EventEmitter();
    // Scroll handler
    /** @type {HTMLElement} */
    this.scrollNode = null;
    this.scrollTracking = true;
    this.handleScroll = type => {
      const node = this.scrollNode;
      const height = node.scrollHeight;
      const bottom = node.scrollTop + node.offsetHeight;
      const scrollTracking = (
        Math.abs(height - bottom) < SCROLL_TRACKING_TOLERANCE
      );
      if (scrollTracking !== this.scrollTracking) {
        this.scrollTracking = scrollTracking;
        this.events.emit('scrollTrackingChanged', scrollTracking);
        logger.debug('tracking', this.scrollTracking);
      }
    };
    this.ensureScrollTracking = () => {
      if (this.scrollTracking) {
        this.scrollToBottom();
      }
    };
    // Periodic message pruning
    setInterval(() => this.pruneMessages(), MESSAGE_PRUNE_INTERVAL);
  }

  mount(node) {
    // Mount existing root node on top of the new node
    if (this.rootNode) {
      node.appendChild(this.rootNode);
    }
    // Initialize the root node
    else {
      this.rootNode = node;
    }
    // Find scrollable parent
    this.scrollNode = findNearestScrollableParent(this.rootNode);
    this.scrollNode.addEventListener('scroll', this.handleScroll);
    setImmediate(() => {
      this.scrollToBottom();
    });
    // Flush the queue
    if (this.queue.length > 0) {
      this.processBatch(this.queue);
      this.queue = [];
    }
  }

  assignStyle(style = {}) {
    Object.assign(this.rootNode.style, style);
  }

  setHighlight(text, color) {
    if (!text || !color) {
      this.highlightRegex = null;
      this.highlightColor = null;
      return;
    }
    const lines = String(text)
      .split(',')
      .map(str => str.trim());
    this.highlightRegex = new RegExp('(' + lines.join('|') + ')', 'gi');
    this.highlightColor = color;
  }

  scrollToBottom() {
    // scrollHeight is always bigger than scrollTop and is
    // automatically clamped to the valid range.
    this.scrollNode.scrollTop = this.scrollNode.scrollHeight;
  }

  changePage(page) {
    this.page = page;
    // Fast clear of the root node
    this.rootNode.textContent = '';
    this.visibleMessages = [];
    // Re-add message nodes
    const fragment = document.createDocumentFragment();
    let node;
    for (let message of this.messages) {
      if (canPageAcceptType(page, message.type)) {
        node = message.node;
        fragment.appendChild(node);
        this.visibleMessages.push(message);
      }
    }
    if (node) {
      this.rootNode.appendChild(fragment);
      node.scrollIntoView();
    }
  }

  getCombinableMessage(predicate) {
    const now = Date.now();
    const len = this.visibleMessages.length;
    const from = len - 1;
    const to = Math.max(0, len - COMBINE_MAX_MESSAGES);
    for (let i = from; i >= to; i--) {
      const message = this.visibleMessages[i];
      const matches = (
        // Is not an internal message
        !message.type.startsWith('internal')
        // Text payload must fully match
        && message.text === predicate.text
        // Must land within the specified time window
        && now < message.createdAt + COMBINE_MAX_TIME_WINDOW
      );
      if (matches) {
        return message;
      }
    }
    return null;
  }

  processBatch(batch, options = {}) {
    const {
      prepend,
      notifyListeners = true,
    } = options;
    const now = Date.now();
    // Queue up messages until chat is mounted
    if (!this.rootNode) {
      for (let payload of batch) {
        if (prepend) {
          this.queue.unshift(payload);
        }
        else {
          this.queue.push(payload);
        }
      }
      return;
    }
    // Insert messages
    const fragment = document.createDocumentFragment();
    const countByType = {};
    let node;
    for (let payload of batch) {
      const message = createMessage(payload);
      // Combine messages
      const combinable = this.getCombinableMessage(message);
      if (combinable) {
        combinable.times = (combinable.times || 1) + 1;
        updateMessageBadge(combinable);
        continue;
      }
      // Reuse message node
      if (message.node) {
        node = message.node;
      }
      // Reconnected
      else if (message.type === 'internal/reconnected') {
        node = createReconnectedNode();
      }
      // Create message node
      else {
        node = createMessageNode();
        node.innerHTML = message.text;
        // Highlight text
        if (this.highlightRegex) {
          const highlighted = highlightNode(node,
            this.highlightRegex,
            text => (
              createHighlightNode(text, this.highlightColor)
            ));
          if (highlighted) {
            node.className += ' ChatMessage--highlighted';
          }
        }
        // Assign an image error handler
        if (now < message.createdAt + IMAGE_RETRY_MESSAGE_AGE) {
          for (let imgNode of node.querySelectorAll('img')) {
            imgNode.addEventListener('error', handleImageError);
          }
        }
        // Store the node in the message
        message.node = node;
      }
      // Query all possible selectors to find out the message type
      if (!message.type) {
        const typeDef = MESSAGE_TYPES.find(typeDef => (
          typeDef.selector && node.querySelector(typeDef.selector)
        ));
        message.type = typeDef?.type || 'unknown';
      }
      updateMessageBadge(message);
      if (!countByType[message.type]) {
        countByType[message.type] = 0;
      }
      countByType[message.type] += 1;
      // TODO: Detect duplicates
      this.messages.push(message);
      if (canPageAcceptType(this.page, message.type)) {
        fragment.appendChild(node);
        this.visibleMessages.push(message);
      }
    }
    if (node) {
      const firstChild = this.rootNode.childNodes[0];
      if (prepend && firstChild) {
        this.rootNode.insertBefore(fragment, firstChild);
      }
      else {
        this.rootNode.appendChild(fragment);
      }
      if (this.scrollTracking) {
        setImmediate(() => this.scrollToBottom());
      }
    }
    // Notify listeners that we have processed the batch
    if (notifyListeners) {
      this.events.emit('batchProcessed', countByType);
    }
  }

  pruneMessages() {
    if (!this.rootNode) {
      return;
    }
    const messages = this.visibleMessages;
    const fromIndex = Math.max(0, messages.length - MAX_VISIBLE_MESSAGES);
    this.visibleMessages = messages.slice(fromIndex);
    for (let i = 0; i < fromIndex; i++) {
      const message = messages[i];
      this.rootNode.removeChild(message.node);
    }
    if (fromIndex > 0) {
      logger.log(`pruned ${fromIndex} messages`);
    }
  }

  rebuildChat() {
    if (!this.rootNode) {
      return;
    }
    // Make a copy of messages
    const fromIndex = Math.max(0,
      this.messages.length - MAX_PERSISTED_MESSAGES);
    const messages = this.messages.slice(fromIndex);
    // Remove existing nodes
    for (let message of messages) {
      message.node = undefined;
    }
    // Fast clear of the root node
    this.rootNode.textContent = '';
    this.messages = [];
    this.visibleMessages = [];
    // Repopulate the chat log
    this.processBatch(messages, {
      notifyListeners: false,
    });
  }
}

// Make chat renderer global so that we can continue using the same
// instance after hot code replacement.
if (!window.__chatRenderer__) {
  window.__chatRenderer__ = new ChatRenderer();
}

/** @type {ChatRenderer} */
export const chatRenderer = window.__chatRenderer__;
