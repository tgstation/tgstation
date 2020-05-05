export const enterStandby = () => ({
  type: 'standby',
});

export const standbyReducer = (state, action) => {
  const { type } = action;

  if (type === 'standby') {
    return {
      ...state,
      data: {},
      shared: {},
      config: {
        ...state.config,
        title: '',
        status: 1,
        interface: '',
      },
      standby: true,
    };
  }

  return state;
};
