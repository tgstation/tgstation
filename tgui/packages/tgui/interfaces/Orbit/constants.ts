export const ANTAG2COLOR = {
  'Abductors': 'pink',
  'Ash Walkers': 'olive',
  'Biohazards': 'brown',
  'CentCom': 'teal',
} as const;

export const ANTAG2GROUP = {
  'Abductor Agent': 'Abductors',
  'Abductor Scientist': 'Abductors',
  'Ash Walker': 'Ash Walkers',
  'Blob': 'Biohazards',
  'Sentient Disease': 'Biohazards',
  'CentCom Commander': 'CentCom',
  'CentCom Head Intern': 'CentCom',
  'CentCom Intern': 'CentCom',
  'CentCom Official': 'CentCom',
  'Central Command': 'CentCom',
  'Clown Operative': 'Clown Operatives',
  'Clown Operative Leader': 'Clown Operatives',
  'Nuclear Operative': 'Nuclear Operatives',
  'Nuclear Operative Leader': 'Nuclear Operatives',
  'Space Wizard': 'Wizard Federation',
  'Wizard Apprentice': 'Wizard Federation',
  'Wizard Minion': 'Wizard Federation',
} as const;

export const JOB2ICON = {
  'AI': 'eye',
  'Cyborg': 'robot',
  'Personal AI': 'mobile-alt',
} as const;

export enum THREAT {
  Low = 2,
  Medium = 5,
  High = 8,
}

export enum HEALTH {
  Good = 69,
  Average = 19,
}
