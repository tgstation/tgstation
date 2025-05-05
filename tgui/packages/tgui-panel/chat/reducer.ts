/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { importSettings } from '../settings/actions';
import {
  addChatPage,
  changeChatPage,
  changeScrollTracking,
  loadChat,
  moveChatPageLeft,
  moveChatPageRight,
  removeChatPage,
  toggleAcceptedType,
  updateChatPage,
  updateMessageCount,
} from './actions';
import { canPageAcceptType, createMainPage } from './model';
import { Page } from './types';

const mainPage = createMainPage();

export const initialState = {
  version: 5,
  currentPageId: mainPage.id,
  scrollTracking: true,
  pages: [mainPage.id],
  pageById: {
    [mainPage.id]: mainPage,
  },
};

export const chatReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === loadChat.type) {
    // Validate version and/or migrate state
    if (payload?.version !== state.version) {
      return state;
    }
    // Enable any filters that are not explicitly set, that are
    // enabled by default on the main page.
    // NOTE: This mutates acceptedTypes on the state.
    for (let id of Object.keys(payload.pageById)) {
      const page = payload.pageById[id];
      const filters = page.acceptedTypes;
      const defaultFilters = mainPage.acceptedTypes;
      for (let type of Object.keys(defaultFilters)) {
        if (filters[type] === undefined) {
          filters[type] = defaultFilters[type];
        }
      }
    }
    // Reset page message counts
    // NOTE: We are mutably changing the payload on the assumption
    // that it is a copy that comes straight from the web storage.
    for (let id of Object.keys(payload.pageById)) {
      const page = payload.pageById[id];
      page.unreadCount = 0;
    }
    return {
      ...state,
      ...payload,
    };
  }
  if (type === changeScrollTracking.type) {
    const scrollTracking = payload;
    const nextState = {
      ...state,
      scrollTracking,
    };
    if (scrollTracking) {
      const pageId = state.currentPageId;
      const page = {
        ...state.pageById[pageId],
        unreadCount: 0,
      };
      nextState.pageById = {
        ...state.pageById,
        [pageId]: page,
      };
    }
    return nextState;
  }
  if (type === updateMessageCount.type) {
    const countByType = payload;
    const pages = state.pages.map((id) => state.pageById[id]);
    const currentPage = state.pageById[state.currentPageId];
    const nextPageById = { ...state.pageById };
    for (let page of pages) {
      let unreadCount = 0;
      for (let type of Object.keys(countByType)) {
        // Message does not belong here
        if (!canPageAcceptType(page, type)) {
          continue;
        }
        // Current page is scroll tracked
        if (page === currentPage && state.scrollTracking) {
          continue;
        }
        // This page received the same message which we can read
        // on the current page.
        if (page !== currentPage && canPageAcceptType(currentPage, type)) {
          continue;
        }
        unreadCount += countByType[type];
      }
      if (unreadCount > 0) {
        nextPageById[page.id] = {
          ...page,
          unreadCount: page.unreadCount + unreadCount,
        };
      }
    }
    return {
      ...state,
      pageById: nextPageById,
    };
  }
  if (type === addChatPage.type) {
    return {
      ...state,
      currentPageId: payload.id,
      pages: [...state.pages, payload.id],
      pageById: {
        ...state.pageById,
        [payload.id]: payload,
      },
    };
  }
  if (type === importSettings.type) {
    const pagesById: Record<string, Page>[] = payload.newPages;
    if (!pagesById) {
      return state;
    }
    const newPageIds: string[] = Object.keys(pagesById);
    if (!newPageIds) {
      return state;
    }

    const nextState = {
      ...state,
      currentPageId: newPageIds[0],
      pages: [...newPageIds],
      pageById: { ...pagesById },
    };
    return nextState;
  }
  if (type === changeChatPage.type) {
    const { pageId } = payload;
    const page = {
      ...state.pageById[pageId],
      unreadCount: 0,
    };
    return {
      ...state,
      currentPageId: pageId,
      pageById: {
        ...state.pageById,
        [pageId]: page,
      },
    };
  }
  if (type === updateChatPage.type) {
    const { pageId, ...update } = payload;
    const page = {
      ...state.pageById[pageId],
      ...update,
    };
    return {
      ...state,
      pageById: {
        ...state.pageById,
        [pageId]: page,
      },
    };
  }
  if (type === toggleAcceptedType.type) {
    const { pageId, type } = payload;
    const page = { ...state.pageById[pageId] };
    page.acceptedTypes = { ...page.acceptedTypes };
    page.acceptedTypes[type] = !page.acceptedTypes[type];
    return {
      ...state,
      pageById: {
        ...state.pageById,
        [pageId]: page,
      },
    };
  }
  if (type === removeChatPage.type) {
    const { pageId } = payload;
    const nextState = {
      ...state,
      pages: [...state.pages],
      pageById: {
        ...state.pageById,
      },
    };
    delete nextState.pageById[pageId];
    nextState.pages = nextState.pages.filter((id) => id !== pageId);
    if (nextState.pages.length === 0) {
      nextState.pages.push(mainPage.id);
      nextState.pageById[mainPage.id] = mainPage;
      nextState.currentPageId = mainPage.id;
    }
    if (!nextState.currentPageId || nextState.currentPageId === pageId) {
      nextState.currentPageId = nextState.pages[0];
    }
    return nextState;
  }
  if (type === moveChatPageLeft.type) {
    const { pageId } = payload;
    const nextState = {
      ...state,
      pages: [...state.pages],
      pageById: {
        ...state.pageById,
      },
    };
    const tmpPage = nextState.pageById[pageId];
    const fromIndex = nextState.pages.indexOf(tmpPage.id);
    const toIndex = fromIndex - 1;
    // don't ever move leftmost page
    if (fromIndex > 0) {
      // don't ever move anything to the leftmost page
      if (toIndex > 0) {
        const tmp = nextState.pages[fromIndex];
        nextState.pages[fromIndex] = nextState.pages[toIndex];
        nextState.pages[toIndex] = tmp;
      }
    }
    return nextState;
  }

  if (type === moveChatPageRight.type) {
    const { pageId } = payload;
    const nextState = {
      ...state,
      pages: [...state.pages],
      pageById: {
        ...state.pageById,
      },
    };
    const tmpPage = nextState.pageById[pageId];
    const fromIndex = nextState.pages.indexOf(tmpPage.id);
    const toIndex = fromIndex + 1;
    // don't ever move leftmost page
    if (fromIndex > 0) {
      // don't ever move anything out of the array
      if (toIndex < nextState.pages.length) {
        const tmp = nextState.pages[fromIndex];
        nextState.pages[fromIndex] = nextState.pages[toIndex];
        nextState.pages[toIndex] = tmp;
      }
    }
    return nextState;
  }
  return state;
};
