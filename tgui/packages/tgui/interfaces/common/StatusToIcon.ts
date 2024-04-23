export const CRIMESTATUS2COLOR = {
  Arrest: 'bad',
  Discharged: 'blue',
  Incarcerated: 'average',
  Parole: 'good',
  Suspected: 'teal',
} as const;

export enum WantedStatus {
  Arrest = 'Arrest',
  Discharged = 'Discharged',
  Incarcerated = 'Incarcerated',
  Parole = 'Parole',
  Suspected = 'Suspected',
}
