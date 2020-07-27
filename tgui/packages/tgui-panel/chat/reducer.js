import { toArray } from 'common/collections';
import { DEFAULT_PAGE } from './constants';
import { canPageAcceptType } from './selectors';

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
