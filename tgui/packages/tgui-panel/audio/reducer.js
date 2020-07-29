const initialState = {
  playing: false,
};

export const audioReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'audio/playing') {
    return {
      ...state,
      playing: true,
    };
  }
  if (type === 'audio/stopped') {
    return {
      ...state,
      playing: false,
    };
  }
  return state;
};
