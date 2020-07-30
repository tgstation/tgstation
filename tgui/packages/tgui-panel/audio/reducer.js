const initialState = {
  playing: false,
  track: null,
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
  if (type === 'audio/playMusic') {
    return {
      ...state,
      meta: payload,
    };
  }
  if (type === 'audio/stopMusic') {
    return {
      ...state,
      playing: false,
      meta: null,
    };
  }
  return state;
};
