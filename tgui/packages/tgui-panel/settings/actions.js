/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createAction } from 'common/redux';

export const updateSettings = createAction('settings/update');
export const loadSettings = createAction('settings/load');
export const changeSettingsTab = createAction('settings/changeTab');
export const toggleSettings = createAction('settings/toggle');
export const openChatSettings = createAction('settings/openChatTab');
