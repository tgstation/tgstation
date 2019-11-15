const GASES = [
  {
    id: 'o2',
    name: 'oxygen',
    label: 'O₂',
  },
  {
    id: 'n2',
    name: 'nitrogen',
    label: 'N₂',
  },
  {
    id: 'co2',
    name: 'carbon dioxide',
    label: 'CO₂',
  },
  {
    id: 'water_vapor',
    name: 'water vapor',
    label: 'H₂O',
  },
  {
    id: 'n2o',
    name: 'nitrous oxide',
    label: 'N₂O',
  },
  {
    id: 'no2',
    name: 'nitryl',
    label: 'NO₂',
  },
  {
    id: 'bz',
    label: 'BZ',
  },
];

export const getGasLabel = (gasId, fallbackValue) => {
  if (!gasId) {
    return fallbackValue || gasId;
  }
  const gas = GASES.find(gas => gas.id === gasId
    || gas.name === gasId.toLowerCase());
  if (!gas) {
    return fallbackValue || gasId;
  }
  return gas.label;
};
