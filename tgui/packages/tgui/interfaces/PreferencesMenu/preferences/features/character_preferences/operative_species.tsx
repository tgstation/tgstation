import { CheckboxInput, FeatureToggle } from '../base';

export const operative_species: FeatureToggle = {
  name: 'Always Human as Operative',
  description:
    'If true, you will always spawn as a human (this means your backup human if an alien species) when you roll nuclear operative.',
  component: CheckboxInput,
};
