import { CheckboxInput, FeatureToggle } from '../base';

export const story_pref: FeatureToggle = {
  name: 'Be story participant',
  category: 'GAMEPLAY',
  description: 'Toggles whether you wish to participate in stories or not.',
  component: CheckboxInput,
};
