/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const selectChat = (state) => state.chat;

export const selectChatPages = (state) =>
  state.chat.pages.map((id: string) => state.chat.pageById[id]);

export const selectCurrentChatPage = (state) =>
  state.chat.pageById[state.chat.currentPageId];

export const selectChatPageById = (id) => (state) => state.chat.pageById[id];
