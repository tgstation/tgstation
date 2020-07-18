window.__chat__ = {};

export const chat = window.__chat__;

chat.mount = element => {
  chat.rootElement = element;
};

export const chatMiddleware = store => next => action => {
  const { type, payload } = action;
  if (type === 'chat/message') {
    if (chat.rootElement) {
      const batch = Array.isArray(payload) ? payload : [payload];
      const fragment = document.createDocumentFragment();
      let element;
      for (let payload of batch) {
        element = document.createElement('div');
        element.innerHTML = payload.text;
        fragment.appendChild(element);
      }
      if (element) {
        chat.rootElement.appendChild(fragment);
        element.scrollIntoView();
      }
    }
    return;
  }
  return next(action);
};
