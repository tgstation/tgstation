import { storage } from 'common/storage';
import { createLogger } from 'tgui/logging';
import { changeChatPage, loadChat, updateMessageCount } from './actions';
import { MAX_PERSISTED_MESSAGES, MESSAGE_SAVE_INTERVAL } from './constants';
import { chatRenderer, createReconnectedMessage, serializeMessage } from './renderer';
import { selectChat } from './selectors';

const logger = createLogger('chat/middleware');

const saveChatToStorage = async store => {
  const state = selectChat(store.getState());
  const fromIndex = Math.max(0,
    chatRenderer.messages.length - MAX_PERSISTED_MESSAGES);
  const messages = chatRenderer.messages
    .slice(fromIndex)
    .filter(message => message.type !== 'internal')
    .map(message => serializeMessage(message));
  storage.set('chat-state', state);
  storage.set('chat-messages', messages);
};

const loadChatFromStorage = async store => {
  storage.get('chat-state').then(state => {
    if (state) {
      store.dispatch(loadChat(state));
    }
  });
  storage.get('chat-messages').then(messages => {
    if (messages) {
      chatRenderer.processBatch([
        ...messages,
        createReconnectedMessage(),
      ]);
    }
  });
};

export const chatMiddleware = store => {
  let initialized = false;
  chatRenderer.events.on('batchProcessed', countByType => {
    store.dispatch(updateMessageCount(countByType));
  });
  setInterval(() => saveChatToStorage(store), MESSAGE_SAVE_INTERVAL);
  return next => action => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      loadChatFromStorage(store);
      return next(action);
    }
    if (type === 'chat/message') {
      // Normalize the payload
      const batch = Array.isArray(payload) ? payload : [payload];
      chatRenderer.processBatch(batch);
      return;
    }
    if (type === changeChatPage.type) {
      const page = payload;
      chatRenderer.changePage(page);
      return next(action);
    }
    if (type === 'roundrestart') {
      // Save chat as soon as possible
      saveChatToStorage(store);
      return next(action);
    }
    return next(action);
  };
};
