import { storage } from 'common/storage';
import { useAtom, useAtomValue } from 'jotai';
import { useEffect } from 'react';
import { highlightsAtom, settingsAtom, settingsLoadedAtom } from './atoms';
import { generalSettingsHandler } from './helpers';
import { startSettingsMigration } from './migration';
import { setDisplayScaling } from './scaling';
import type { SettingsState } from './types';

/** Custom hook that handles loading and updating settings from storage. */
export function useSettings() {
  const [settings, setSettings] = useAtom(settingsAtom);
  const highlights = useAtomValue(highlightsAtom);

  const [loaded, setLoaded] = useAtom(settingsLoadedAtom);

  /** Load and migrate settings */
  useEffect(() => {
    if (loaded) return;

    async function fetchSettings(): Promise<void> {
      try {
        const storedSettings = await storage.get('panel-settings');
        console.log('Loaded panel settings from storage:', storedSettings);
        startSettingsMigration(storedSettings);
      } catch (error) {
        console.error('Failed to load panel settings:', error);
      }
    }

    fetchSettings();
    setDisplayScaling();
    setLoaded(true);
  }, []);

  function storeSettings(update: SettingsState): void {
    setSettings(update);
    console.log('Updated panel settings:', update);
    storage.set('panel-settings', { ...update, ...highlights });
  }

  /** Updates any set of keys. Offers type safety based on the selection */
  function updateSettings<TKey extends keyof SettingsState>(
    update: Record<TKey, SettingsState[TKey]>,
  ): void {
    const newSettings: SettingsState = {
      ...settings,
      ...update,
    };

    generalSettingsHandler(newSettings);
    storeSettings(newSettings);
  }

  return { settings, updateSettings };
}
