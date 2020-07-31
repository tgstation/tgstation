import { createAction } from 'common/redux';

export const changeChatPage = createAction('chat/changePage');
export const updateMessageCount = createAction('chat/updateMessageCount');
export const loadChat = createAction('chat/load');
