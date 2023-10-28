import { FeatureChoiced, FeatureDropdownInput } from '../base';

export const prisoner_crime: FeatureChoiced = {
  name: 'Prisoner crime',
  description:
    'When signing up as a prisoner, this will be added to your records as the reason for your arrest.',
  component: FeatureDropdownInput,
};
