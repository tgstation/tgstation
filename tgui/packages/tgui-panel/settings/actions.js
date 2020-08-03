/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const updateSettings = (settings = {}) => ({
  type: 'settings/update',
  payload: settings,
});

export const loadSettings = (settings = {}) => ({
  type: 'settings/load',
  payload: settings,
});
