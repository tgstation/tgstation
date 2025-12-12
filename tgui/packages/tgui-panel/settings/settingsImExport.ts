import { useDispatch } from 'tgui/backend';
import type { Page } from '../chat/types';
import { store } from '../events/store';
import { importSettings } from './actions';
import { storedSettingsAtom } from './atoms';
import { startSettingsMigration } from './migration';

export function exportChatSettings(pages: Record<string, Page>): void {
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

  const pagesEntry = { chatPages: pages };

  const exportObject = Object.assign(settings, pagesEntry);

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
  const dispatch = useDispatch();
  if (Array.isArray(settings)) {
    return;
  }
  const ourImport = JSON.parse(settings);
  if (!ourImport?.version) return;

  let pageRecord: Record<string, Page>[] = [];
  if ('chatPages' in ourImport) {
    pageRecord = ourImport.chatPages;
    delete ourImport.chatPages;
  }

  dispatch(importSettings(ourImport, pageRecord));
  startSettingsMigration(ourImport);
}
