import { storage } from 'common/storage';
import { useAtom, useAtomValue } from 'jotai';
import { useEffect } from 'react';
import { highlightsAtom, settingsAtom } from './atoms';
import { generalSettingsHandler } from './helpers';
import { startSettingsMigration } from './migration';
import { setDisplayScaling } from './scaling';
import type { SettingsState } from './types';

let initialized = false;

/** Custom hook that handles loading and updating settings from storage. */
export function useSettings() {
  const [settings, setSettings] = useAtom(settingsAtom);
  const highlights = useAtomValue(highlightsAtom);

  /** Load and migrate settings */
  useEffect(() => {
    if (initialized) return;
    initialized = true;

    async function fetchSettings() {
      try {
        const storedSettings = await storage.get('panel-settings');
        if (!storedSettings) return;
        console.log('Loaded panel settings from storage:', storedSettings);

        startSettingsMigration(storedSettings);
      } catch (error) {
        console.error('Failed to load panel settings:', error);
      }
    }

    fetchSettings();
    setDisplayScaling();
  }, []);

  /** Updates any set of keys. Offers type safety based on the selection */
  function updateSettings<TKey extends keyof SettingsState>(
    update: Record<TKey, SettingsState[TKey]>,
  ): void {
    const newSettings = {
      ...settings,
      ...update,
    };

    generalSettingsHandler(newSettings);
    setSettings(newSettings);
    console.log('Updated panel settings:', newSettings);
    storage.set('panel-settings', { ...newSettings, ...highlights });
  }

  return { settings, updateSettings };
}
