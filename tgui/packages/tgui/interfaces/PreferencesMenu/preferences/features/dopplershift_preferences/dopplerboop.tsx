import { CheckboxInput, FeatureToggle } from '../base';

export const hear_dopplerboop: FeatureToggle = {
  name: 'Enable voice mumbles',
  category: 'SOUND',
  description:
    'Adds a semi-syllable based voice generation system to all characters.',
  component: CheckboxInput,
};
