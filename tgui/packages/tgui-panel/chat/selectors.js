import { toArray } from 'common/collections';

export const selectChat = state => state.chat;

export const selectChatPages = state => (
  toArray(state.chat.pageById)
);

export const selectCurrentChatPage = state => (
  state.chat.pageById[state.chat.currentPage]
);

export const selectChatPageById = id => state => (
  state.chat.pageById[id]
);

export const canPageAcceptType = (page, type) => (
  page.acceptedTypes[type]
);
