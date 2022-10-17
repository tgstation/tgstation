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
  // Cargo
  'Cargo Technician': 'box',
  'Shaft Miner': 'digging',
  'Quartermaster': 'sack-dollar',
  // Command
  'Captain': 'crown',
  'Head of Personnel': 'dog',
  // Engineering
  'Atmospheric Technician': 'fan',
  'Chief Engineer': 'user-astronaut',
  'Station Engineer': 'gears',
  // Medical
  'Chemist': 'prescription-bottle',
  'Chief Medical Officer': 'user-md',
  'Medical Doctor': 'staff-snake',
  'Paramedic': 'truck-medical',
  'Psychologist': 'brain',
  'Virologist': 'virus',
  // Science
  'Geneticist': 'dna',
  'Research Director': 'user-graduate',
  'Roboticist': 'battery-half',
  'Scientist': 'flask',
  // Service
  'Assistant': 'toolbox',
  'Bartender': 'cocktail',
  'Botanist': 'seedling',
  'Chaplain': 'cross',
  'Chef': 'utensils',
  'Clown': 'face-grin-tears',
  'Cook': 'utensils',
  'Curator': 'book',
  'Janitor': 'broom',
  'Mime': 'comment-slash',
  // Security
  'Detective': 'user-secret',
  'Head of Security': 'user-shield',
  'Prisoner': 'lock-keyhole',
  'Security Officer': 'shield-halved',
  'Security Officer (Cargo)': 'shield-halved',
  'Security Officer (Engineering)': 'shield-halved',
  'Security Officer (Medical)': 'shield-halved',
  'Security Officer (Science)': 'shield-halved',
  'Warden': 'handcuffs',
  'Lawyer': 'gavel',
  // Silicon
  'AI': 'eye',
  'Cyborg': 'robot',
  'pAI': 'robot',
} as const;

export enum THREAT {
  Low = 2,
  Medium = 5,
  High = 8,
}

export enum HEALTH {
  Good = 75,
  Average = 20,
}
