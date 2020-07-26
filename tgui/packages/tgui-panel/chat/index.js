import { toArray } from 'common/collections';
import { shallowDiffers } from 'common/react';
import { Component, createRef } from 'inferno';
import { logger } from 'tgui/logging';
import { DEFAULT_PAGE, MESSAGE_TYPES } from './constants';

export const chat = new class Chat {
  constructor() {
    /** @type {HTMLElement} */
    this.rootNode = null;
    this.queue = [];
    this.messages = [];
    this.page = DEFAULT_PAGE;
  }

  mount(node) {
    if (!this.rootNode) {
      this.rootNode = node;
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
    return countByType;
  }
};

export const selectChatPages = state => (
  toArray(state.chat.pageById)
);

export const selectCurrentChatPage = state => (
  state.chat.pageById[state.chat.currentPage]
);

export const selectChatPageById = id => state => (
  state.chat.pageById[id]
);

const canPageAcceptType = (page, type) => page.acceptedTypes[type];

export const changeChatPage = page => ({
  type: 'chat/changePage',
  payload: { page },
});

export const updateMessageCount = countByType => ({
  type: 'chat/updateMessageCount',
  payload: { countByType },
});

export const initialState = {
  currentPage: DEFAULT_PAGE.id,
  pageById: {
    [DEFAULT_PAGE.id]: DEFAULT_PAGE,
    radio: {
      id: 'radio',
      name: 'Radio',
      count: 0,
      acceptedTypes: {
        radio: true,
      },
    },
    inspect: {
      id: 'inspect',
      name: 'Inspect',
      count: 0,
      acceptedTypes: {
        info: true,
      },
    },
    unknown: {
      id: 'unknown',
      name: 'Unsorted',
      count: 0,
      acceptedTypes: {
        unknown: true,
      },
    },
  },
};

export const chatReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'chat/changePage') {
    const { page } = payload;
    return {
      ...state,
      currentPage: page.id,
    };
  }
  if (type === 'chat/updateMessageCount') {
    const { countByType } = payload;
    const pages = toArray(state.pageById);
    const nextPageById = { ...state.pageById };
    for (let page of pages) {
      let count = page.count || 0;
      for (let type of Object.keys(countByType)) {
        if (canPageAcceptType(page, type)) {
          count += countByType[type];
        }
      }
      if (page.count !== count) {
        nextPageById[page.id] = { ...page, count };
      }
    }
    return {
      ...state,
      pageById: nextPageById,
    };
  }
  return state;
};

export const chatMiddleware = store => {
  logger.log(store.getState());
  return next => action => {
    const { type, payload } = action;
    if (type === 'chat/message') {
      // Normalize the payload
      const batch = Array.isArray(payload) ? payload : [payload];
      const countByType = chat.processBatch(batch);
      return next(updateMessageCount(countByType));
    }
    if (type === 'chat/changePage') {
      const { page } = payload;
      chat.changePage(page);
      return next(action);
    }
    return next(action);
  };
};

export class Chat extends Component {
  constructor() {
    super();
    this.ref = createRef();
  }

  componentDidMount() {
    chat.mount(this.ref.current);
    this.componentDidUpdate();
  }

  shouldComponentUpdate(nextProps) {
    return shallowDiffers(this.props, nextProps);
  }

  componentDidUpdate() {
    chat.assignStyle({
      width: '100%',
      whiteSpace: 'pre-wrap',
      fontSize: this.props.fontSize,
      lineHeight: this.props.lineHeight,
    });
  }

  render() {
    return (
      <div ref={this.ref} />
    );
  }
}
