export const PHYSICALSTATUS2COLOR = {
  Active: 'good',
  'Physically Unfit': 'purple',
  Unconscious: 'average',
  Deceased: 'bad',
} as const;

export const PHYSICALSTATUS2DESC = {
  Active: 'Active. Individual is conscious and healthy.',
  'Physically Unfit':
    'Physically Unfit. Individual is conscious, but unhealthy.',
  Unconscious: 'Unconscious. Individual may require medical attention.',
  Deceased: 'Deceased. Individual has died and begun to decay.',
} as const;

export const MENTALSTATUS2COLOR = {
  Stable: 'good',
  Watch: 'purple',
  Unstable: 'average',
  Insane: 'bad',
} as const;

export const MENTALSTATUS2DESC = {
  Stable: 'Stable. Individual is sane and free from psychological disorders.',
  Watch:
    'Watch. Individual has symptoms of mental illness. Monitor them closely.',
  Unstable: 'Unstable. Individual has one or more mental illnesses.',
  Insane: 'Insane. Individual exhibits severe, abnormal mental behaviors.',
} as const;
