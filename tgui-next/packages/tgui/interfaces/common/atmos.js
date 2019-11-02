const GASES = [
  {
    id: 'o2',
    label: 'O₂',
  },
  {
    id: 'n2',
    label: 'N₂',
  },
  {
    id: 'co2',
    label: 'CO₂',
  },
  {
    id: 'water_vapor',
    label: 'H₂O',
  },
  {
    id: 'n2o',
    label: 'N₂O',
  },
  {
    id: 'no2',
    label: 'NO₂',
  },
  {
    id: 'bz',
    label: 'BZ',
  },
];

export const getGasLabel = (gasId, fallbackValue) => {
  const gas = GASES.find(gas => gas.id === gasId);
  if (!gas) {
    return fallbackValue || gasId;
  }
  return gas.label;
};
