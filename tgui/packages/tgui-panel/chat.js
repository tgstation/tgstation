import { shallowDiffers } from 'common/react';
import { Component, createRef } from 'inferno';

export const chat = {
  root: null,
  queue: [],
};

window.__chat__ = chat;

chat.mount = element => {
  if (!chat.root) {
    chat.root = element;
    handleIncomingMessages(chat.queue);
    chat.queue = [];
    return;
  }
  element.appendChild(chat.root);
};

const handleIncomingMessages = batch => {
  // Queue up messages until chat is mounted
  if (!chat.root) {
    for (let payload of batch) {
      chat.queue.push(payload);
    }
    return;
  }
  // Insert messages
  const fragment = document.createDocumentFragment();
  let element;
  for (let payload of batch) {
    element = document.createElement('div');
    element.innerHTML = payload.text;
    fragment.appendChild(element);
  }
  if (element) {
    chat.root.appendChild(fragment);
    element.scrollIntoView();
  }
};

export const chatMiddleware = store => next => action => {
  const { type, payload } = action;
  if (type === 'chat/message') {
    // Normalize the payload
    const batch = Array.isArray(payload) ? payload : [payload];
    handleIncomingMessages(batch);
    return;
  }
  return next(action);
};

export class Chat extends Component {
  constructor() {
    super();
    this.chatRef = createRef();
  }

  componentDidMount() {
    chat.mount(this.chatRef.current);
    this.componentDidUpdate();
  }

  shouldComponentUpdate(nextProps) {
    return shallowDiffers(this.props, nextProps);
  }

  componentDidUpdate() {
    chat.root.style.width = "100%";
    chat.root.style.whiteSpace = 'pre-wrap';
    chat.root.style.fontSize = this.props.fontSize;
    chat.root.style.lineHeight = this.props.lineHeight;
  }

  render() {
    return (
      <div ref={this.chatRef} />
    );
  }
}
