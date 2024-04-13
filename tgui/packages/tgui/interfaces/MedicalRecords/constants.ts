export const PHYSICALSTATUS2ICON = {
  Active: 'person-running',
  Debilitated: 'crutch',
  Unconscious: 'moon-o',
  Deceased: 'skull',
};

export const PHYSICALSTATUS2COLOR = {
  Active: 'green',
  Debilitated: 'purple',
  Unconscious: 'orange',
  Deceased: 'red',
} as const;

export const PHYSICALSTATUS2DESC = {
  Active: 'Active. Individual is conscious and healthy.',
  Debilitated: 'Debilitated. Individual is conscious, but unhealthy.',
  Unconscious: 'Unconscious. Individual may require medical attention.',
  Deceased: 'Deceased. Individual has died and begun to decay.',
} as const;

export const MENTALSTATUS2ICON = {
  Stable: 'face-smile-o',
  Watch: 'eye-o',
  Unstable: 'scale-unbalanced-flip',
  Insane: 'head-side-virus',
};

export const MENTALSTATUS2COLOR = {
  Stable: 'green',
  Watch: 'purple',
  Unstable: 'orange',
  Insane: 'red',
} as const;

export const MENTALSTATUS2DESC = {
  Stable: 'Stable. Individual is sane and free from psychological disorders.',
  Watch:
    'Watch. Individual has symptoms of mental illness. Monitor them closely.',
  Unstable: 'Unstable. Individual has one or more mental illnesses.',
  Insane: 'Insane. Individual exhibits severe, abnormal mental behaviors.',
} as const;
