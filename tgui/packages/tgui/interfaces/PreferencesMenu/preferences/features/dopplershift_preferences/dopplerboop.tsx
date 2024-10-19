import {
  CheckboxInput,
  FeatureNumeric,
  FeatureSliderInput,
  FeatureToggle,
} from '../base';

export const hear_dopplerboop: FeatureToggle = {
  name: 'Enable voice mumbles',
  category: 'SOUND',
  description:
    'Adds a semi-syllable based voice generation system to all characters.',
  component: CheckboxInput,
};

export const voice_volume: FeatureNumeric = {
  name: 'Voice volume',
  category: 'SOUND',
  description: 'Sets the volume used for dopplerboop voices.',
  component: FeatureSliderInput,
};
