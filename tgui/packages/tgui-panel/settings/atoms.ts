import { atom } from 'jotai';
import { FONTS, SETTINGS_TABS } from './constants';
import type { HighlightSetting, HighlightState, SettingsState } from './types';

export const defaultSettings: SettingsState = {
  adminMusicVolume: 0.5,
  fontFamily: FONTS[0],
  fontSize: 13,
  initialized: false,
  lineHeight: 1.2,
  statFontSize: 12,
  statLinked: true,
  statTabsStyle: 'default',
  theme: 'light',
  version: 1,
  view: {
    visible: false,
    activeTab: SETTINGS_TABS[0].id,
  },
};

export const defaultHighlightSetting: HighlightSetting = {
  id: 'default',
  highlightText: '',
  highlightColor: '#ffdd44',
  highlightWholeMessage: true,
  matchWord: false,
  matchCase: false,
};

const initialHighlights: HighlightState = {
  highlightSettings: ['default'],
  highlightSettingById: {
    default: defaultHighlightSetting,
  },
  // Keep these two state vars for compatibility with other servers
  highlightText: '',
  highlightColor: '#ffdd44',
  // END compatibility state vars
};

export const settingsAtom = atom(defaultSettings);
export const settingsVisibleAtom = atom(false);

export const highlightsAtom = atom(initialHighlights);

export const storedSettingsAtom = atom((get) => ({
  ...get(settingsAtom),
  ...get(highlightsAtom),
}));
