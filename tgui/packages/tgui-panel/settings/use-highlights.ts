import { storage } from 'common/storage';
import { useAtom, useAtomValue } from 'jotai';
import { createUuid } from 'tgui-core/uuid';
import { chatRenderer } from '../chat/renderer';
import { defaultHighlightSetting, highlightsAtom, settingsAtom } from './atoms';
import type { HighlightSetting, HighlightState } from './types';

/** Custom hook with utility functions for updating highlight settings */
export function useHighlights() {
  const [highlights, setHighlights] = useAtom(highlightsAtom);
  const settings = useAtomValue(settingsAtom);

  function storeHighlights(update: HighlightState): void {
    setHighlights(update);
    storage.set('panel-settings', {
      ...settings,
      ...update,
    });
    chatRenderer.setHighlight(
      update.highlightSettings,
      update.highlightSettingById,
    );
  }

  function updateHighlight(
    update: Partial<HighlightSetting> & { id: string },
  ): void {
    const { id } = update;
    const current = highlights.highlightSettingById[id];
    if (!current) return;

    // Copies highlights and updates the specified setting
    const draft: HighlightState['highlightSettingById'] = {
      ...highlights.highlightSettingById,
      [id]: {
        ...current,
        ...update,
      },
    };

    // Reconstruct the overall highlight structure
    const newState: HighlightState = {
      ...highlights,
      highlightSettings: Object.keys(draft),
      highlightSettingById: draft,
    };

    // Update state and persist to storage
    storeHighlights(newState);
  }

  function removeHighlight(id: string): void {
    const draft: Record<string, HighlightSetting> = {};
    // Rebuild the highlight settings without the specified id
    for (const key in highlights.highlightSettingById) {
      if (key !== id) {
        draft[key] = highlights.highlightSettingById[key];
      }
    }

    const draftKeys = highlights.highlightSettings.filter((key) => key !== id);

    // Ensure the default highlight setting always exists
    if (id === defaultHighlightSetting.id) {
      draft[defaultHighlightSetting.id] = defaultHighlightSetting;
      draftKeys.unshift(defaultHighlightSetting.id);
    }

    // Construct the updated highlight settings structure
    const newState: HighlightState = {
      ...highlights,
      highlightSettingById: draft,
      highlightSettings: draftKeys,
    };

    // Update state and persist to storage
    storeHighlights(newState);
  }

  function addHighlight(): void {
    const draft: HighlightSetting = {
      ...defaultHighlightSetting,
      id: createUuid(),
    };

    // Append to the existing highlight settings
    const updatedIds: HighlightState['highlightSettingById'] = {
      ...highlights.highlightSettingById,
      [draft.id]: draft,
    };

    // Reconstruct the overall highlight settings structure
    const newState: HighlightState = {
      ...highlights,
      highlightSettings: [...highlights.highlightSettings, draft.id],
      highlightSettingById: updatedIds,
    };

    // Update state and persist to storage
    storeHighlights(newState);
  }

  return {
    highlights,
    updateHighlight,
    removeHighlight,
    addHighlight,
  };
}
