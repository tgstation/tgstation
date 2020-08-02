import { EventEmitter } from 'common/events';
import { classes } from 'common/react';
import { createLogger } from 'tgui/logging';
import { COMBINE_MAX_MESSAGES, COMBINE_MAX_TIME_WINDOW, DEFAULT_PAGE, MAX_VISIBLE_MESSAGES, MESSAGE_PRUNE_INTERVAL, MESSAGE_TYPES } from './constants';
import { canPageAcceptType } from './selectors';

const logger = createLogger('chatRenderer');

// We consider this as the smallest possible scroll offset
// that is still trackable.
const SCROLL_EPSILON_PX = 32;

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
    node = node.parentElement;
  }
  return window;
};

export const createMessage = payload => ({
  ...payload,
  createdAt: Date.now(),
});

export const serializeMessage = message => ({
  type: message.type,
  text: message.text,
  times: message.times,
  createdAt: message.createdAt,
});

export const createReconnectedMessage = () => {
  const node = document.createElement('div');
  node.className = 'Chat__reconnected';
  return createMessage({
    type: 'internal',
    text: 'Reconnected',
    node,
  });
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
    // Event subscribers
    this.subscribers = {
      batchProcessed: [],
      scrollTrackingChanged: [],
    };
    // Scroll handler
    /** @type {HTMLElement} */
    this.scrollNode = null;
    this.scrollTracking = true;
    this.handleScroll = type => {
      const node = this.scrollNode;
      const height = node.scrollHeight;
      const bottom = node.scrollTop + node.offsetHeight;
      const scrollTracking = (
        Math.abs(height - bottom) < SCROLL_EPSILON_PX
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
        // Text payload must fully match
        message.text === predicate.text
        // Must land within the specified time window
        && now < message.createdAt + COMBINE_MAX_TIME_WINDOW
      );
      if (matches) {
        return message;
      }
    }
    return null;
  }

  processBatch(batch) {
    // Queue up messages until chat is mounted
    if (!this.rootNode) {
      for (let payload of batch) {
        this.queue.push(payload);
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
      // Create message node
      else {
        node = document.createElement('div');
        node.innerHTML = message.text;
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
      this.rootNode.appendChild(fragment);
      if (this.scrollTracking) {
        setImmediate(() => this.scrollToBottom());
      }
    }
    // Notify subscribers that we have processed the batch
    this.events.emit('batchProcessed', countByType);
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
    logger.log(`pruned ${fromIndex} messages`);
  }
}

// Make chat renderer global so that we can continue using the same
// instance after hot code replacement.
if (!window.__chatRenderer__) {
  window.__chatRenderer__ = new ChatRenderer();
}

/** @type {ChatRenderer} */
export const chatRenderer = window.__chatRenderer__;
