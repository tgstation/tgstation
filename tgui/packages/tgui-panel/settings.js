export const selectSettings = state => state?.settings || {};

export const updateSettings = (settings = {}) => ({
  type: 'settings/update',
  payload: settings,
});

const initialState = {
  fontSize: 12,
  lineHeight: 1.5,
};

export const settingsReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'settings/update') {
    return {
      ...state,
      ...payload,
    };
  }
  return state;
};

export const settingsMiddleware = store => next => action => {
  // TODO: Persistence of settings
  return next(action);
};
