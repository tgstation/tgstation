import { classes } from 'common/react';
import { EventEmitter } from 'common/events';
import { createLogger } from 'tgui/logging';
import { DEFAULT_PAGE, MESSAGE_TYPES } from './constants';
import { canPageAcceptType } from './selectors';

const logger = createLogger('chatRenderer');

const COMBINE_MAX_MESSAGES = 3;
const COMBINE_MAX_TIME_WINDOW = 5000;

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
    this.handleScroll = () => {
      const height = this.scrollNode.scrollHeight;
      const bottom = this.scrollNode.scrollTop
        + this.scrollNode.offsetHeight;
      const scrollTracking = (
        Math.abs(height - bottom) < SCROLL_EPSILON_PX
      );
      if (scrollTracking !== this.scrollTracking) {
        this.scrollTracking = scrollTracking;
        this.events.emit('scrollTrackingChanged', scrollTracking);
        logger.debug('tracking', this.scrollTracking);
      }
    };
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
    this.scrollToBottom();
    // Flush the queue
    if (this.queue.length > 0) {
      this.queue = [];
      this.processBatch(this.queue);
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
      const message = { ...payload };
      // Combine messages
      const combinable = this.getCombinableMessage(message);
      if (combinable) {
        const node = combinable.node;
        combinable.times = (combinable.times || 1) + 1;
        // Add the combined message badge
        const foundBadge = node.querySelector('.Chat__badge');
        const badge = foundBadge || document.createElement('div');
        badge.textContent = combinable.times;
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
        continue;
      }
      // Create message node
      node = document.createElement('div');
      node.innerHTML = message.text;
      // Store the node in the message
      message.node = node;
      // Store a timestamp
      message.createdAt = Date.now();
      // Query all possible selectors to find out the message type
      if (!message.type) {
        const typeDef = MESSAGE_TYPES.find(typeDef => (
          typeDef.selector && node.querySelector(typeDef.selector)
        ));
        message.type = typeDef?.type || 'unknown';
      }
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
        this.scrollToBottom();
      }
    }
    // Notify subscribers that we have processed the batch
    this.events.emit('batchProcessed', countByType);
  }
}

// Make chat renderer global so that we can continue using the same
// instance after hot code replacement.
if (!window.__chatRenderer__) {
  window.__chatRenderer__ = new ChatRenderer();
}

/** @type {ChatRenderer} */
export const chatRenderer = window.__chatRenderer__;
