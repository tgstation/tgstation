// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    captain: '#c06616',
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    centcom: '#00c100',
    other: '#c38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
};

// Colors defined in CSS
export const CSS_COLORS = [
  'black',
  'white',
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'good',
  'average',
  'bad',
  'label',
];

export const RADIO_CHANNELS = [
  {
    name: 'Syndicate',
    freq: 1213,
    color: '#a52a2a',
  },
  {
    name: 'Red Team',
    freq: 1215,
    color: '#ff4444',
  },
  {
    name: 'Blue Team',
    freq: 1217,
    color: '#3434fd',
  },
  {
    name: 'CentCom',
    freq: 1337,
    color: '#2681a5',
  },
  {
    name: 'Supply',
    freq: 1347,
    color: '#b88646',
  },
  {
    name: 'Service',
    freq: 1349,
    color: '#6ca729',
  },
  {
    name: 'Science',
    freq: 1351,
    color: '#c68cfa',
  },
  {
    name: 'Command',
    freq: 1353,
    color: '#5177ff',
  },
  {
    name: 'Medical',
    freq: 1355,
    color: '#57b8f0',
  },
  {
    name: 'Engineering',
    freq: 1357,
    color: '#f37746',
  },
  {
    name: 'Security',
    freq: 1359,
    color: '#dd3535',
  },
  {
    name: 'AI Private',
    freq: 1447,
    color: '#d65d95',
  },
  {
    name: 'Common',
    freq: 1459,
    color: '#1ecc43',
  },
];
