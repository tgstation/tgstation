import { CheckboxInput, type FeatureToggle } from '../base';

export const particle_weather: FeatureToggle = {
  name: 'Enable particle weather',
  category: 'GAMEPLAY',
  description:
    'Enable fancy particle weather. Incompatible with AMD GPUs due to a BYOND bug.',
  component: CheckboxInput,
};
