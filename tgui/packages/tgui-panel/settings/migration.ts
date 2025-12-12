import { chatRenderer } from '../chat/renderer';
import { store } from '../events/store';
import {
  defaultHighlightSetting,
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

/** Initializes new settings */
function mergeSettings(next: SettingsState): SettingsState {
  const nextState = {
    ...defaultSettings,
    ...next,
    initialized: true,
    view: defaultSettings.view, // Preserve view state
  };

  return nextState;
}

/** A bit of a chunky procedural function. Handles imported and loaded settings */
export function startSettingsMigration(
  next: SettingsState & HighlightState,
): void {
  generalSettingsHandler(next);

  const migratedSettings = mergeSettings(next);
  store.set(settingsAtom, migratedSettings);
  console.log('Migrated panel settings:', migratedSettings);

  if (next.version) {
    const migratedHighlights = migrateHighlights(next);
    store.set(highlightsAtom, migratedHighlights);

    chatRenderer.setHighlight(
      migratedHighlights.highlightSettings,
      migratedHighlights.highlightSettingById,
    );
    console.log('Migrated panel highlight settings:', migratedHighlights);
  }
}
