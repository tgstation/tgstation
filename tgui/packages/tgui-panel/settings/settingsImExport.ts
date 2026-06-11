import { omit } from 'es-toolkit';
import { chatPagesRecordAtom, mainPage } from '../chat/atom';
import { startChatStateMigration } from '../chat/migration';
import type { Page, StoredChatSettings } from '../chat/types';
import { store } from '../events/store';
import { storedSettingsAtom } from './atoms';
import { startSettingsMigration } from './migration';
import type { ExportedSettings } from './types';

export function exportChatSettings(): void {
  const chatPages = store.get(chatPagesRecordAtom);
  const settings = store.get(storedSettingsAtom);

  const opts: SaveFilePickerOptions = {
    id: `ss13-chatprefs-${Date.now()}`,
    suggestedName: `ss13-chatsettings-${new Date().toJSON().slice(0, 10)}.json`,
    types: [
      {
        description: 'SS13 file',
        accept: { 'application/json': ['.json'] },
      },
    ],
  };

  const exportObject = { ...settings, chatPages };

  window
    .showSaveFilePicker(opts)
    .then((fileHandle) => {
      fileHandle.createWritable().then((writableHandle) => {
        writableHandle.write(JSON.stringify(exportObject));
        writableHandle.close();
      });
    })
    .catch((e) => {
      // Log the error if the error has nothing to do with the user aborting the download
      if (e.name !== 'AbortError') {
        console.error(e);
      }
    });
}

export function importChatSettings(settings: string | string[]): void {
  if (Array.isArray(settings)) return;

  let ourImport: ExportedSettings;
  try {
    ourImport = JSON.parse(settings);
  } catch (err) {
    console.error(err);
    return;
  }

  const settingsPart = omit(ourImport, ['chatPages']);

  if ('chatPages' in ourImport && ourImport.chatPages) {
    const chatPart = rebuildChatState(ourImport.chatPages);
    if (chatPart) {
      startChatStateMigration(chatPart);
    }
  }

  startSettingsMigration(settingsPart);
}

/** Reconstructs chat settings from just the record */
function rebuildChatState(
  pageRecord: Record<string, Page>,
): StoredChatSettings | undefined {
  const newPageIds: string[] = Object.keys(pageRecord);
  if (newPageIds.length === 0) return;

  // Correct any missing keys from the import
  const merged: Record<string, Page> = { ...pageRecord };
  for (const page of newPageIds) {
    merged[page] = {
      ...mainPage,
      ...pageRecord[page],
      unreadCount: 0,
    };
  }

  const rebuiltState: StoredChatSettings = {
    version: 5,
    scrollTracking: true,
    currentPageId: newPageIds[0],
    pages: newPageIds,
    pageById: merged,
  };

  return rebuiltState;
}
