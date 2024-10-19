import { Feature, FeatureNumberInput } from '../base';

export const age: Feature<number> = {
  name: 'Age',
  /* DOPPLER ADDITION START */
  description:
    "The character's physical age, in years.  This is the age their body should be, ignoring any type of stasis or time manipulation.",
  /* DOPPLER ADDITION END */
  component: FeatureNumberInput,
};
