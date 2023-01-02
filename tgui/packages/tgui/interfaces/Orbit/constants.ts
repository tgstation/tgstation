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
  'Blob Spore': 'Biohazards',
  'Blobbernaut': 'Biohazards',
  'Sentient Disease': 'Biohazards',

  'Admiral': 'CentCom',
  'CentCom Bartender': 'CentCom',
  'CentCom Commander': 'CentCom',
  'CentCom Head Intern': 'CentCom',
  'CentCom Intern': 'CentCom',
  'CentCom Official': 'CentCom',
  'Central Command': 'CentCom',
  'Custodian': 'CentCom',
  'Private Security Force': 'CentCom',
  'VIP Guest': 'CentCom',

  'Clown Operative': 'Clown Operatives',
  'Clown Operative Leader': 'Clown Operatives',

  'Death Squad Officer': 'Emergency Response Team',
  'Death Squad Trooper': 'Emergency Response Team',
  'Emergency Response Team Commander': 'Emergency Response Team',
  'Security Response Officer': 'Emergency Response Team',
  'Engineering Response Officer': 'Emergency Response Team',
  'Medical Response Officer': 'Emergency Response Team',
  'Religious Response Officer': 'Emergency Response Team',
  'Janitorial Response Officer': 'Emergency Response Team',
  'Entertainment Response Officer': 'Emergency Response Team',
  'Emergency Response Officer': 'Emergency Response Team',

  'Nuclear Operative': 'Nuclear Operatives',
  'Nuclear Operative Leader': 'Nuclear Operatives',

  'Space Wizard': 'Wizard Federation',
  'Wizard Apprentice': 'Wizard Federation',
  'Wizard Minion': 'Wizard Federation',
} as const;

export const THREAT = {
  Low: 1,
  Medium: 5,
  High: 8,
} as const;

export const HEALTH = {
  Good: 69, // nice
  Average: 19,
} as const;
