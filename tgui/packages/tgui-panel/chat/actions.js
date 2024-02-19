/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createAction } from 'common/redux';

import { createPage } from './model';

export const loadChat = createAction('chat/load');
export const rebuildChat = createAction('chat/rebuild');
export const clearChat = createAction('chat/clear');
export const updateMessageCount = createAction('chat/updateMessageCount');
export const addChatPage = createAction('chat/addPage', () => ({
  payload: createPage(),
}));
export const changeChatPage = createAction('chat/changePage');
export const updateChatPage = createAction('chat/updatePage');
export const toggleAcceptedType = createAction('chat/toggleAcceptedType');
export const removeChatPage = createAction('chat/removePage');
export const changeScrollTracking = createAction('chat/changeScrollTracking');
export const saveChatToDisk = createAction('chat/saveToDisk');
export const moveChatPageLeft = createAction('chat/movePageLeft');
export const moveChatPageRight = createAction('chat/movePageRight');
