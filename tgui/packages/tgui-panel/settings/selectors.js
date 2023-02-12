/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const selectSettings = (state) => state.settings;
export const selectActiveTab = (state) => state.settings.view.activeTab;
export const selectHighlightSettings = (state) =>
  state.settings.highlightSettings;
export const selectHighlightSettingById = (state) =>
  state.settings.highlightSettingById;
