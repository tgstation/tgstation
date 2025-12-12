import { storage } from 'common/storage';
import { omit, pick } from 'es-toolkit';
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
import type { HighlightState, SettingsState } from './types';

/** Fixes issues with stored highlight settings */
function migrateHighlights(next: HighlightState): HighlightState {
  const draft: HighlightState = { ...next };

  // Lazy init the list for compatibility reasons
  if (!draft.highlightSettings) {
    draft.highlightSettings = [defaultHighlightSetting.id];
    draft.highlightSettingById[defaultHighlightSetting.id] =
      defaultHighlightSetting;
  }
  // Compensating for mishandling of default highlight settings
  else if (!draft.highlightSettingById[defaultHighlightSetting.id]) {
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
export function startSettingsMigration(
  next: SettingsState & HighlightState,
): void {
  const settingsPart = omit(next, highlightKeys);
  const highlightPart = pick(next, highlightKeys);

  const draftSettings: SettingsState = {
    ...defaultSettings,
    ...settingsPart,
    initialized: true,
    view: defaultSettings.view, // Preserve view state
  };

  generalSettingsHandler(draftSettings);
  store.set(settingsAtom, draftSettings);
  console.log('Migrated panel settings:', draftSettings);

  const migratedHighlights = migrateHighlights(highlightPart);

  // Just exit if no valid storage was found
  if (!next?.version) {
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
