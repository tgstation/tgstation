
export const to_exponential_if_big = (value) => {
  if (Math.abs(value) > 5000) {
    return value.toExponential(1);
  }
  return Math.round(value);
};

const ActParam = (key, value) => {
  const ret = {};
  ret[key] = value;
  return ret;
};

export const ActNone = (act, key) => () => act(key);

export const ActFixed = (act, key, val) => () => act(key, ActParam(key, val));

export const ActSet = (act, key) => (e, val) => act(key, ActParam(key, val));
