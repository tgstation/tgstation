type Gas = {
  id: string;
  path: string;
  name: string;
  label: string;
  color: string;
};

const gases = [
  {
    id: 'o2',
    path: '/datum/gas/oxygen',
    name: 'Oxygen',
    label: 'O₂',
    color: 'blue',
  },
  {
    id: 'n2',
    path: '/datum/gas/nitrogen',
    name: 'Nitrogen',
    label: 'N₂',
    color: 'yellow',
  },
  {
    id: 'co2',
    path: '/datum/gas/carbon_dioxide',
    name: 'Carbon Dioxide',
    label: 'CO₂',
    color: 'grey',
  },
  {
    id: 'plasma',
    path: '/datum/gas/plasma',
    name: 'Plasma',
    label: 'Plasma',
    color: 'pink',
  },
  {
    id: 'water_vapor',
    path: '/datum/gas/water_vapor',
    name: 'Water Vapor',
    label: 'H₂O',
    color: 'lightsteelblue',
  },
  {
    id: 'hypernoblium',
    path: '/datum/gas/hypernoblium',
    name: 'Hyper-noblium',
    label: 'Hyper-nob',
    color: 'teal',
  },
  {
    id: 'n2o',
    path: '/datum/gas/nitrous_oxide',
    name: 'Nitrous Oxide',
    label: 'N₂O',
    color: 'bisque',
  },
  {
    id: 'no2',
    path: '/datum/gas/nitrium',
    name: 'Nitrium',
    label: 'Nitrium',
    color: 'brown',
  },
  {
    id: 'tritium',
    path: '/datum/gas/tritium',
    name: 'Tritium',
    label: 'Tritium',
    color: 'limegreen',
  },
  {
    id: 'bz',
    path: '/datum/gas/bz',
    name: 'BZ',
    label: 'BZ',
    color: 'mediumpurple',
  },
  {
    id: 'pluoxium',
    path: '/datum/gas/pluoxium',
    name: 'Pluoxium',
    label: 'Pluoxium',
    color: 'mediumslateblue',
  },
  {
    id: 'miasma',
    path: '/datum/gas/miasma',
    name: 'Miasma',
    label: 'Miasma',
    color: 'olive',
  },
  {
    id: 'freon',
    path: '/datum/gas/freon',
    name: 'Freon',
    label: 'Freon',
    color: 'paleturquoise',
  },
  {
    id: 'hydrogen',
    path: '/datum/gas/hydrogen',
    name: 'Hydrogen',
    label: 'H₂',
    color: 'white',
  },
  {
    id: 'healium',
    path: '/datum/gas/healium',
    name: 'Healium',
    label: 'Healium',
    color: 'salmon',
  },
  {
    id: 'proto_nitrate',
    path: '/datum/gas/proto_nitrate',
    name: 'Proto Nitrate',
    label: 'Proto-Nitrate',
    color: 'greenyellow',
  },
  {
    id: 'zauker',
    path: '/datum/gas/zauker',
    name: 'Zauker',
    label: 'Zauker',
    color: 'darkgreen',
  },
  {
    id: 'halon',
    path: '/datum/gas/halon',
    name: 'Halon',
    label: 'Halon',
    color: 'purple',
  },
  {
    id: 'helium',
    path: '/datum/gas/helium',
    name: 'Helium',
    label: 'He',
    color: 'aliceblue',
  },
  {
    id: 'antinoblium',
    path: '/datum/gas/antinoblium',
    name: 'Antinoblium',
    label: 'Anti-Noblium',
    color: 'maroon',
  },
  {
    id: 'nitrium',
    path: '/datum/gas/nitrium',
    name: 'Nitrium',
    label: 'Nitrium',
    color: 'brown',
  },
] as const;

// Returns gas label based on gasId
export function getGasLabel(gasId: string, fallbackValue?: string) {
  if (!gasId) return fallbackValue || 'None';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < gases.length; idx++) {
    if (gases[idx].id === gasSearchString) {
      return gases[idx].label;
    }
  }

  return fallbackValue || 'None';
}

// Returns gas color based on gasId
export function getGasColor(gasId: string) {
  if (!gasId) return 'black';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < gases.length; idx++) {
    if (gases[idx].id === gasSearchString) {
      return gases[idx].color;
    }
  }

  return 'black';
}

// Returns gas object based on gasId
export function getGasFromId(gasId: string): Gas | undefined {
  if (!gasId) return;

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < gases.length; idx++) {
    if (gases[idx].id === gasSearchString) {
      return gases[idx];
    }
  }
}

// Returns gas object based on gasPath
export function getGasFromPath(gasPath: string): Gas | undefined {
  if (!gasPath) return;

  for (let idx = 0; idx < gases.length; idx++) {
    if (gases[idx].path === gasPath) {
      return gases[idx];
    }
  }
}
