/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import {
  addHighlightSetting,
  changeSettingsTab,
  loadSettings,
  openChatSettings,
  removeHighlightSetting,
  toggleSettings,
  updateHighlightSetting,
  updateSettings,
} from './actions';
import { FONTS, MAX_HIGHLIGHT_SETTINGS, SETTINGS_TABS } from './constants';
import { createDefaultHighlightSetting } from './model';

const defaultHighlightSetting = createDefaultHighlightSetting();

const initialState = {
  version: 1,
  fontSize: 13,
  fontFamily: FONTS[0],
  lineHeight: 1.2,
  theme: 'light',
  adminMusicVolume: 0.5,
  // Keep these two state vars for compatibility with other servers
  highlightText: '',
  highlightColor: '#ffdd44',
  // END compatibility state vars
  highlightSettings: [defaultHighlightSetting.id],
  highlightSettingById: {
    [defaultHighlightSetting.id]: defaultHighlightSetting,
  },
  view: {
    visible: false,
    activeTab: SETTINGS_TABS[0].id,
  },
  statLinked: true,
  statFontSize: 12,
  statTabsStyle: 'default',
} as const;

export function settingsReducer(
  state = initialState,
  action: { type: string; payload: any },
) {
  const { type, payload } = action;

  switch (type) {
    case updateSettings.type:
      return {
        ...state,
        ...payload,
      };

    case loadSettings.type: {
      {
        // Validate version and/or migrate state
        if (!payload?.version) {
          return state;
        }

        delete payload.view;
        const nextState = {
          ...state,
          ...payload,
        };
        // Lazy init the list for compatibility reasons
        if (!nextState.highlightSettings) {
          nextState.highlightSettings = [defaultHighlightSetting.id];
          nextState.highlightSettingById[defaultHighlightSetting.id] =
            defaultHighlightSetting;
        }
        // Compensating for mishandling of default highlight settings
        else if (!nextState.highlightSettingById[defaultHighlightSetting.id]) {
          nextState.highlightSettings = [
            defaultHighlightSetting.id,
            ...nextState.highlightSettings,
          ];
          nextState.highlightSettingById[defaultHighlightSetting.id] =
            defaultHighlightSetting;
        }

        // Update the highlight settings for default highlight
        // settings compatibility
        const highlightSetting =
          nextState.highlightSettingById[defaultHighlightSetting.id];
        highlightSetting.highlightColor = nextState.highlightColor;
        highlightSetting.highlightText = nextState.highlightText;

        return nextState;
      }
    }

    case toggleSettings.type: {
      return {
        ...state,
        view: {
          ...state.view,
          visible: !state.view.visible,
        },
      };
    }

    case openChatSettings.type: {
      return {
        ...state,
        view: {
          ...state.view,
          visible: true,
          activeTab: 'chatPage',
        },
      };
    }

    case changeSettingsTab.type: {
      const { tabId } = payload;

      return {
        ...state,
        view: {
          ...state.view,
          activeTab: tabId,
        },
      };
    }

    case addHighlightSetting.type: {
      const highlightSetting = payload;

      if (state.highlightSettings.length >= MAX_HIGHLIGHT_SETTINGS) {
        return state;
      }

      return {
        ...state,
        highlightSettings: [...state.highlightSettings, highlightSetting.id],
        highlightSettingById: {
          ...state.highlightSettingById,
          [highlightSetting.id]: highlightSetting,
        },
      };
    }

    case removeHighlightSetting.type: {
      const { id } = payload;

      const nextState = {
        ...state,
        highlightSettings: [...state.highlightSettings],
        highlightSettingById: {
          ...state.highlightSettingById,
        },
      };

      if (id === defaultHighlightSetting.id) {
        nextState.highlightSettings[defaultHighlightSetting.id] =
          defaultHighlightSetting;
      } else {
        delete nextState.highlightSettingById[id];
        nextState.highlightSettings = nextState.highlightSettings.filter(
          (sid) => sid !== id,
        );
        if (!nextState.highlightSettings.length) {
          nextState.highlightSettings.push(defaultHighlightSetting.id);
          nextState.highlightSettingById[defaultHighlightSetting.id] =
            defaultHighlightSetting;
        }
      }

      return nextState;
    }

    case updateHighlightSetting.type: {
      const { id, ...settings } = payload;

      const nextState = {
        ...state,
        highlightSettings: [...state.highlightSettings],
        highlightSettingById: {
          ...state.highlightSettingById,
        },
      };

      // Transfer this data from the default highlight setting
      // so they carry over to other servers
      if (id === defaultHighlightSetting.id) {
        if (settings.highlightText) {
          nextState.highlightText = settings.highlightText;
        }
        if (settings.highlightColor) {
          nextState.highlightColor = settings.highlightColor;
        }
      }

      if (nextState.highlightSettingById[id]) {
        nextState.highlightSettingById[id] = {
          ...nextState.highlightSettingById[id],
          ...settings,
        };
      }

      return nextState;
    }
  }

  return state;
}
