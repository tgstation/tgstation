export const changeChatPage = page => ({
  type: 'chat/changePage',
  payload: { page },
});

export const updateMessageCount = countByType => ({
  type: 'chat/updateMessageCount',
  payload: { countByType },
});
