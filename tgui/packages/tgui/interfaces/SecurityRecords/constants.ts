export const CRIMESTATUS2COLOR = {
  Arrest: 'bad',
  Discharged: 'good',
  Incarcerated: 'average',
  Parole: 'blue',
  Suspected: 'purple',
} as const;

export const CRIMESTATUS2DESC = {
  Arrest: 'Arrest. Target must have valid crimes to set this status.',
  Discharged: 'Discharged. Individual has been acquitted from wrongdoing.',
  Incarcerated: 'Incarcerated. Individual is currently serving a sentence.',
  Parole: 'Parole. Released from prison, but still under supervision.',
  Suspected: 'Suspected. Monitor closely for criminal activity.',
} as const;
