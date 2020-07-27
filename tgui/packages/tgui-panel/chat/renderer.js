import { DEFAULT_PAGE, MESSAGE_TYPES } from './constants';
import { canPageAcceptType } from './selectors';

export const chatRenderer = new class ChatRenderer {
  constructor() {
    /** @type {HTMLElement} */
    this.rootNode = null;
    this.queue = [];
    this.messages = [];
    this.page = DEFAULT_PAGE;
    // Event subscribers
    this.onBatchProcesedSubscribers = [];
  }

  mount(node) {
    if (!this.rootNode) {
      this.rootNode = node;
      // Flush the queue
      this.queue = [];
      this.processBatch(this.queue);
      return;
    }
    node.appendChild(this.rootNode);
  }

  assignStyle(style = {}) {
    Object.assign(this.rootNode.style, style);
  }

  changePage(page) {
    this.page = page;
    // Fast clear of the root node
    this.rootNode.textContent = '';
    // Re-add message nodes
    const fragment = document.createDocumentFragment();
    let node;
    for (let message of this.messages) {
      if (canPageAcceptType(page, message.type)) {
        node = message.node;
        fragment.appendChild(node);
      }
    }
    if (node) {
      this.rootNode.appendChild(fragment);
      node.scrollIntoView();
    }
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
      node = document.createElement('div');
      node.innerHTML = message.text;
      // Store the node in the message
      message.node = node;
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
      }
    }
    if (node) {
      this.rootNode.appendChild(fragment);
      node.scrollIntoView();
    }
    // Notify subscribers that we have processed the batch
    for (let subscriber of this.onBatchProcesedSubscribers) {
      subscriber(countByType);
    }
  }

  onBatchProcesed(subscriber) {
    this.onBatchProcesedSubscribers.push(subscriber);
  }
};
