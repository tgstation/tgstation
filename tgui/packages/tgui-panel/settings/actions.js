export const updateSettings = (settings = {}) => ({
  type: 'settings/update',
  payload: settings,
});

export const toggleSettings = () => ({
  type: 'settings/toggle',
});
