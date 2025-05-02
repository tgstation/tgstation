/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createAction } from 'common/redux';

import { createHighlightSetting } from './model';

export const updateSettings = createAction('settings/update');
export const loadSettings = createAction('settings/load');
export const changeSettingsTab = createAction('settings/changeTab');
export const toggleSettings = createAction('settings/toggle');
export const openChatSettings = createAction('settings/openChatTab');
export const addHighlightSetting = createAction(
  'settings/addHighlightSetting',
  () => ({
    payload: createHighlightSetting(),
  }),
);
export const removeHighlightSetting = createAction(
  'settings/removeHighlightSetting',
);
export const updateHighlightSetting = createAction(
  'settings/updateHighlightSetting',
);
export const exportSettings = createAction('settings/export');
export const importSettings = createAction(
  'settings/import',
  (settings, pages) => ({
    payload: { newSettings: settings, newPages: pages },
  }),
);
