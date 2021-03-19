export const CHROMOSOME_NEVER = 0;
export const CHROMOSOME_NONE = 1;
export const CHROMOSOME_USED = 2;

export const CONSOLE_MODE_ENZYMES = 'enzymes';
export const CONSOLE_MODE_SEQUENCER = 'sequencer';
export const CONSOLE_MODE_STORAGE = 'storage';

export const GENES = ['A', 'T', 'C', 'G'];
export const GENE_COLORS = {
  A: 'green',
  T: 'green',
  G: 'blue',
  C: 'blue',
  X: 'grey',
};

export const MUT_NORMAL = 1;
export const MUT_EXTRA = 2;

export const STORAGE_CONS_SUBMODE_MUTATIONS = 'mutations';
export const STORAGE_CONS_SUBMODE_CHROMOSOMES = 'chromosomes';

export const STORAGE_DISK_SUBMODE_MUTATIONS = 'mutations';
export const STORAGE_DISK_SUBMODE_ENZYMES = 'diskenzymes';

export const STORAGE_MODE_CONSOLE = 'console';
export const STORAGE_MODE_DISK = 'disk';
export const STORAGE_MODE_ADVINJ = 'injector';

export const SUBJECT_CONCIOUS = 0;
export const SUBJECT_SOFT_CRIT = 1;
export const SUBJECT_UNCONSCIOUS = 2;
export const SUBJECT_DEAD = 3;
export const SUBJECT_TRANSFORMING = 4;

export const RADIATION_STRENGTH_MAX = 15;
export const RADIATION_DURATION_MAX = 30;

// __DEFINES/DNA.dm - Mutation "Quality"
const POSITIVE = 1;
const NEGATIVE = 2;
const MINOR_NEGATIVE = 4;
export const MUT_COLORS = {
  [POSITIVE]: 'good',
  [NEGATIVE]: 'bad',
  [MINOR_NEGATIVE]: 'average',
};
