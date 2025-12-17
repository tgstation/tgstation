import { storage } from 'common/storage';
import DOMPurify from 'dompurify';
import { useAtom, useAtomValue, useSetAtom } from 'jotai';
import { useEffect } from 'react';
import * as z from 'zod';
import { settingsLoadedAtom } from '../settings/atoms';
import {
  allChatAtom,
  chatLoadedAtom,
  chatPagesAtom,
  chatPagesRecordAtom,
  currentPageIdAtom,
  mainPage,
  scrollTrackingAtom,
  versionAtom,
} from './atom';
import { MESSAGE_SAVE_INTERVAL } from './constants';
import { saveChatToStorage } from './helpers';
import { createMessage } from './model';
import { chatRenderer } from './renderer';

// List of blacklisted tags
const FORBID_TAGS = ['a', 'iframe', 'link', 'video'];

const storedSettingsSchema = z.object({
  version: z.number(),
  scrollTracking: z.boolean(),
  currentPageId: z.string(),
  pages: z.array(z.string()),
  pageById: z.record(z.string(), z.any()),
});

type StoredChatSettings = z.infer<typeof storedSettingsSchema>;

/**
 * Custom hook that initializes chat from local storage and periodically saves
 * it back
 */
export function useChatPersistence() {
  const [version, setVersion] = useAtom(versionAtom);
  const setScrollTracking = useSetAtom(scrollTrackingAtom);
  const setChatPages = useSetAtom(chatPagesAtom);
  const setCurrentPageId = useSetAtom(currentPageIdAtom);
  const setChatPagesRecord = useSetAtom(chatPagesRecordAtom);

  const allChat = useAtomValue(allChatAtom);

  const [loaded, setLoaded] = useAtom(chatLoadedAtom);
  const settingsLoaded = useAtomValue(settingsLoadedAtom);

  /** Loads chat + chat settings */
  useEffect(() => {
    if (loaded || !settingsLoaded) return;

    let cancelled = false;

    async function fetchChat(): Promise<void> {
      console.log('Initializing chat');
      await loadChatFromStorage();

      if (!cancelled) {
        setLoaded(true);
      }
    }

    fetchChat();

    return () => {
      cancelled = true;
    };
  }, [loaded, settingsLoaded, setLoaded]);

  /** Periodically saves chat + chat settings */
  useEffect(() => {
    if (!loaded) return;

    const saveInterval = setInterval(saveChatToStorage, MESSAGE_SAVE_INTERVAL);
    return () => clearInterval(saveInterval);
  }, [loaded]);

  /** Saves chat settings shortly after any settings change */
  useEffect(() => {
    if (!loaded) return;

    const timeout = setTimeout(() => {
      // Avoid persisting frequently-changing unread counts.
      const pageById = Object.fromEntries(
        Object.entries(allChat.pageById).map(([id, page]) => [
          id,
          {
            ...page,
            unreadCount: 0,
          },
        ]),
      );

      storage.set('chat-state', {
        ...allChat,
        pageById,
      });
    }, 750);

    return () => clearTimeout(timeout);
  }, [loaded, allChat]);

  async function loadChatFromStorage(): Promise<void> {
    const [state, messages] = await Promise.all([
      storage.get('chat-state'),
      storage.get('chat-messages'),
    ]);

    if (messages) {
      handleMessages(messages);
    }

    // Discard incompatible versions
    if (state && 'version' in state && state.version <= 4) return;
    console.log('Loaded chat state from storage:', state);
    handleSettings(state);
  }

  function handleMessages(messages: any[]): void {
    for (const message of messages) {
      if (message.html) {
        message.html = DOMPurify.sanitize(message.html, {
          FORBID_TAGS,
        });
      }
    }

    const batch = [
      ...messages,
      createMessage({
        type: 'internal/reconnected',
      }),
    ];

    chatRenderer.processBatch(batch, {
      prepend: true,
    });

    console.log(`Restored chat with ${messages.length} messages`);
  }

  function handleSettings(state: StoredChatSettings): void {
    let parsed: StoredChatSettings;
    try {
      parsed = storedSettingsSchema.parse(state);
    } catch (err) {
      console.error(err);
      return;
    }

    // Validate version and/or migrate state
    if (parsed.version !== version) return;

    // Enable any filters that are not explicitly set, that are
    // enabled by default on the main page.
    for (const id of parsed.pages) {
      const page = parsed.pageById[id];
      const filters = page.acceptedTypes;

      const defaultFilters = mainPage.acceptedTypes;
      for (const type of Object.keys(defaultFilters)) {
        if (filters[type] === undefined) {
          filters[type] = defaultFilters[type];
        }
      }
      // Reset page message counts
      page.unreadCount = 0;
    }

    setVersion(parsed.version);
    setScrollTracking(parsed.scrollTracking);
    setChatPages(parsed.pages);
    setCurrentPageId(parsed.currentPageId);
    setChatPagesRecord(parsed.pageById);

    chatRenderer.changePage(parsed.pageById[parsed.currentPageId]);
    chatRenderer.onStateLoaded();
    console.log('Restored chat settings:', parsed);
  }
}
