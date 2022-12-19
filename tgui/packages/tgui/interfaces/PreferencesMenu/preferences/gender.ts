export type Gender = 'Male' | 'Female' | 'Other';

export const GENDERS: Record<Gender, { icon: string; text: string }> = {
  Male: {
    icon: 'male',
    text: 'Male',
  },

  Female: {
    icon: 'female',
    text: 'Female',
  },

  Other: {
    icon: 'tg-non-binary',
    text: 'Other',
  },
};
