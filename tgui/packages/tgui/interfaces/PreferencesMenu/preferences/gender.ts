export enum Gender {
  Male = 'male',
  Female = 'female',
  Other = 'plural',
  Other2 = 'neuter',
}

export const GENDERS = {
  [Gender.Male]: {
    icon: 'mars',
    text: 'Он/Его',
  },

  [Gender.Female]: {
    icon: 'venus',
    text: 'Она/Ее',
  },

  [Gender.Other]: {
    icon: 'transgender',
    text: 'Они/Их',
  },

  [Gender.Other2]: {
    icon: 'neuter',
    text: 'Это/Его',
  },
};
