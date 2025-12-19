import { omit, pick } from 'es-toolkit';
import { chatPagesRecordAtom } from '../chat/atom';
import { importChatState } from '../chat/helpers';
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

  const chatPart = pick(ourImport, ['chatPages']);
  const settingsPart = omit(ourImport, ['chatPages']);

  if (chatPart) {
    importChatState(chatPart as any);
  }
  startSettingsMigration(settingsPart as any);
}
