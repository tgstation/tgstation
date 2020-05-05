export const enterStandby = () => ({
  type: 'standby',
});

export const standbyReducer = (state, action) => {
  const { type } = action;

  if (type === 'standby') {
    return {
      standby: true,
    };
  }

  return state;
};
