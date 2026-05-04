import { storage } from 'common/storage';
import DOMPurify from 'dompurify';
import { useAtom, useAtomValue } from 'jotai';
import { useEffect } from 'react';
import { settingsLoadedAtom } from '../settings/atoms';
import { chatLoadedAtom, versionAtom } from './atom';
import { MESSAGE_SAVE_INTERVAL } from './constants';
import { saveChatToStorage } from './helpers';
import { startChatStateMigration } from './migration';
import { createMessage } from './model';
import { chatRenderer } from './renderer';

// List of blacklisted tags
const FORBID_TAGS = ['a', 'iframe', 'link', 'video'];

/**
 * Custom hook that initializes chat from local storage and periodically saves
 * it back
 */
export function useChatPersistence() {
  const version = useAtomValue(versionAtom);

  const [loaded, setLoaded] = useAtom(chatLoadedAtom);
  const settingsLoaded = useAtomValue(settingsLoadedAtom);

  /** Loads chat + chat settings */
  useEffect(() => {
    if (!loaded && settingsLoaded) {
      async function fetchChat(): Promise<void> {
        console.log('Initializing chat');
        await loadChatFromStorage();

        setLoaded(true);
        chatRenderer.onStateLoaded();
      }

      fetchChat();
    }
  }, [loaded, settingsLoaded, setLoaded]);

  /** Periodically saves chat + chat settings */
  useEffect(() => {
    let saveInterval: NodeJS.Timeout;

    if (loaded) {
      saveInterval = setInterval(saveChatToStorage, MESSAGE_SAVE_INTERVAL);
    }

    return () => clearInterval(saveInterval);
  }, [loaded]);

  async function loadChatFromStorage(): Promise<void> {
    const [state, messages] = await Promise.all([
      storage.get('chat-state'),
      storage.get('chat-messages'),
    ]);

    if (messages) {
      handleMessages(messages);
    }

    // Empty settings, set defaults
    if (!state) {
      console.log('Initialized chat with default settings');
    } else if (state && 'version' in state && state.version === version) {
      console.log('Loaded chat state from storage:', state);
      startChatStateMigration(state);
    } else {
      // Discard incompatible versions
      console.log('Discarded incompatible chat state from storage:', state);
    }
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
}
