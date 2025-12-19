import { storage } from 'common/storage';
import { smoothMerge } from 'common/type-safety';
import { omit, pick } from 'es-toolkit';
import { setMusicVolume } from '../audio/handlers';
import { chatRenderer } from '../chat/renderer';
import { store } from '../events/store';
import {
  defaultHighlightSetting,
  type defaultHighlights,
  defaultSettings,
  highlightsAtom,
  settingsAtom,
} from './atoms';
import { generalSettingsHandler } from './helpers';
import {
  type HighlightState,
  type MergedSettings,
  type SettingsState,
  settingsSchema,
} from './types';

/** Fixes issues with stored highlight settings */
function migrateHighlights(next: HighlightState): HighlightState {
  const draft: HighlightState = { ...next };

  // Lazy init the list for compatibility reasons
  if (!draft.highlightSettings) {
    draft.highlightSettings = [defaultHighlightSetting.id];
  }

  if (!draft.highlightSettingById) {
    draft.highlightSettingById = {
      [defaultHighlightSetting.id]: defaultHighlightSetting,
    };
  }

  // Compensating for mishandling of default highlight settings
  if (!draft.highlightSettingById[defaultHighlightSetting.id]) {
    draft.highlightSettings = [
      defaultHighlightSetting.id,
      ...draft.highlightSettings,
    ];
    draft.highlightSettingById[defaultHighlightSetting.id] =
      defaultHighlightSetting;
  }

  // Update the highlight settings for default highlight
  // settings compatibility — don't overwrite existing values
  const defaultHighlight =
    draft.highlightSettingById[defaultHighlightSetting.id];

  if (!defaultHighlight.highlightColor) {
    defaultHighlight.highlightColor =
      draft.highlightColor ?? defaultHighlightSetting.highlightColor;
  }

  if (!defaultHighlight.highlightText) {
    defaultHighlight.highlightText =
      draft.highlightText ?? defaultHighlightSetting.highlightText;
  }

  return draft;
}

const highlightKeys: (keyof typeof defaultHighlights)[] = [
  'highlightSettings',
  'highlightSettingById',
  'highlightText',
  'highlightColor',
] as const;

/** A bit of a chunky procedural function. Handles imported and loaded settings */
export function startSettingsMigration(next: MergedSettings): void {
  // No stored settings found, initialize with defaults
  if (!next) {
    const initialized: SettingsState = {
      ...defaultSettings,
      initialized: true,
    };
    storage.set('panel-settings', initialized);
    store.set(settingsAtom, initialized);
    console.log('Initialized settings with defaults.');
    return;
  }

  // Split the merged object as we save in two different atoms
  const settingsPart = omit(next, highlightKeys);
  const highlightPart = pick(next, highlightKeys);

  const draftSettings = smoothMerge({
    source: settingsPart,
    target: defaultSettings,
    schema: settingsSchema,
  });
  draftSettings.initialized = true;
  draftSettings.view = defaultSettings.view; // Preserve view state

  generalSettingsHandler(draftSettings);
  setMusicVolume(draftSettings.adminMusicVolume);
  store.set(settingsAtom, draftSettings);
  console.log('Migrated panel settings:', draftSettings);

  const migratedHighlights = migrateHighlights(highlightPart);

  // Just exit if no valid version was found
  if (!next.version) {
    storage.set('panel-settings', { ...draftSettings, ...migratedHighlights });
    return;
  }

  chatRenderer.setHighlight(
    migratedHighlights.highlightSettings,
    migratedHighlights.highlightSettingById,
  );
  store.set(highlightsAtom, migratedHighlights);
  console.log('Migrated panel highlight settings:', migratedHighlights);
}
