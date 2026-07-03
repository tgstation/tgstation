export enum Gender {
  Male = 'male',
  Female = 'female',
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
};
