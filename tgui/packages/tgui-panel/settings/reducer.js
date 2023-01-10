/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { changeSettingsTab, loadSettings, openChatSettings, toggleSettings, updateSettings, addHighlightSetting, removeHighlightSetting, updateHighlightSetting } from './actions';
import { createDefaultHighlightSetting } from './model';
import { SETTINGS_TABS, FONTS, MAX_HIGHLIGHT_SETTINGS } from './constants';

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
};

export const settingsReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === updateSettings.type) {
    return {
      ...state,
      ...payload,
    };
  }
  if (type === loadSettings.type) {
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
  if (type === toggleSettings.type) {
    return {
      ...state,
      view: {
        ...state.view,
        visible: !state.view.visible,
      },
    };
  }
  if (type === openChatSettings.type) {
    return {
      ...state,
      view: {
        ...state.view,
        visible: true,
        activeTab: 'chatPage',
      },
    };
  }
  if (type === changeSettingsTab.type) {
    const { tabId } = payload;
    return {
      ...state,
      view: {
        ...state.view,
        activeTab: tabId,
      },
    };
  }
  if (type === addHighlightSetting.type) {
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
  if (type === removeHighlightSetting.type) {
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
        (sid) => sid !== id
      );
      if (!nextState.highlightSettings.length) {
        nextState.highlightSettings.push(defaultHighlightSetting.id);
        nextState.highlightSettingById[defaultHighlightSetting.id] =
          defaultHighlightSetting;
      }
    }
    return nextState;
  }
  if (type === updateHighlightSetting.type) {
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
  return state;
};
