import { toArray } from 'common/collections';
import { changeChatPage, updateMessageCount } from './actions';
import { DEFAULT_PAGE } from './constants';
import { canPageAcceptType } from './selectors';

export const initialState = {
  currentPage: DEFAULT_PAGE.id,
  pageById: {
    [DEFAULT_PAGE.id]: DEFAULT_PAGE,
  },
};

export const chatReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === changeChatPage.type) {
    const page = payload;
    return {
      ...state,
      currentPage: page.id,
    };
  }
  if (type === updateMessageCount.type) {
    const countByType = payload;
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
