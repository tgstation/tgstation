export const updateSettings = (settings = {}) => ({
  type: 'settings/update',
  payload: settings,
});

export const loadSettings = (settings = {}) => ({
  type: 'settings/load',
  payload: settings,
});
