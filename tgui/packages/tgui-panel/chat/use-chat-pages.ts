import { useAtom, useAtomValue } from 'jotai';
import {
  chatPagesAtom,
  chatPagesRecordAtom,
  currentPageAtom,
  currentPageIdAtom,
  mainPage,
} from './atom';
import { createPage } from './model';
import { chatRenderer } from './renderer';
import type { Page } from './types';

/** Custom hook for handling chat pages state */
export function useChatPages() {
  const [pages, setPages] = useAtom(chatPagesAtom);
  const [pagesRecord, setPagesRecord] = useAtom(chatPagesRecordAtom);
  const [currentPageId, setCurrentPageId] = useAtom(currentPageIdAtom);
  const page = useAtomValue(currentPageAtom);

  function addChatPage(): void {
    const draft = createPage();

    setCurrentPageId(draft.id);
    setPages((prev) => [...prev, draft.id]);
    setPagesRecord((prev) => ({
      ...prev,
      [draft.id]: draft,
    }));

    chatRenderer.changePage(draft);
  }

  function changeChatPage(page: Page): void {
    setCurrentPageId(page.id);

    const draft: Page = {
      ...pagesRecord[page.id],
      unreadCount: 0,
    };

    setPagesRecord({
      ...pagesRecord,
      [page.id]: draft,
    });

    chatRenderer.changePage(draft);
  }

  function moveChatLeft(): void {
    const tmpPage = pagesRecord[currentPageId];
    const fromIndex = pages.indexOf(tmpPage.id);
    const toIndex = fromIndex - 1;

    // don't ever move leftmost page
    if (fromIndex <= 0) return;
    // don't ever move anything to the leftmost page
    if (toIndex <= 0) return;

    const draftPages = [...pages];
    const tmp = draftPages[fromIndex];
    draftPages[fromIndex] = draftPages[toIndex];
    draftPages[toIndex] = tmp;

    setPages(draftPages);
  }

  function moveChatRight(): void {
    const tmpPage = pagesRecord[currentPageId];
    const fromIndex = pages.indexOf(tmpPage.id);
    const toIndex = fromIndex + 1;

    // don't ever move leftmost page
    if (fromIndex <= 0) return;
    // don't ever move anything out of the array
    if (toIndex >= pages.length) return;

    const draftPages = [...pages];
    const tmp = draftPages[fromIndex];
    draftPages[fromIndex] = draftPages[toIndex];
    draftPages[toIndex] = tmp;

    setPages(draftPages);
  }

  function removeChatPage(): void {
    const nextPages = pages.filter((id) => id !== currentPageId);

    // Always keep at least the main page
    const finalPages = nextPages.length > 0 ? nextPages : [mainPage.id];

    const finalRecord =
      nextPages.length > 0
        ? (Object.fromEntries(
            finalPages.map((id) => [id, pagesRecord[id]]),
          ) as Record<string, Page>)
        : { [mainPage.id]: mainPage };

    setPagesRecord(finalRecord);
    setPages(finalPages);
    setCurrentPageId(finalPages[0]);
    chatRenderer.changePage(finalRecord[finalPages[0]]);
  }

  function toggleAcceptedType(type: string): void {
    const current = { ...pagesRecord[currentPageId] };

    const draft: Page = {
      ...current,
      acceptedTypes: {
        ...current.acceptedTypes,
        [type]: !current.acceptedTypes[type],
      },
    };

    setPagesRecord({
      ...pagesRecord,
      [currentPageId]: draft,
    });
  }

  function updateChatPage(page: Partial<Page>): void {
    const draft: Page = {
      ...pagesRecord[currentPageId],
      ...page,
    };

    setPagesRecord({
      ...pagesRecord,
      [currentPageId]: draft,
    });
  }

  return {
    page,
    pages,
    pagesRecord,
    currentPageId,
    addChatPage,
    changeChatPage,
    moveChatLeft,
    moveChatRight,
    removeChatPage,
    toggleAcceptedType,
    updateChatPage,
  };
}
