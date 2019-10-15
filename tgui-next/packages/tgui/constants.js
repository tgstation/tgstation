// Constants used in tgui.
// These are mirrored from the BYOND code.

export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

export const GAS_LABEL_MAPPING = {
  o2: 'O₂',
  n2: 'N₂',
  co2: 'CO₂',
  water_vapor: 'H₂O',
  n2o: 'N₂O',
  no2: 'NO₂',
  bz: 'BZ',
};

export const getGasLabel = name => GAS_LABEL_MAPPING[name] || name;
