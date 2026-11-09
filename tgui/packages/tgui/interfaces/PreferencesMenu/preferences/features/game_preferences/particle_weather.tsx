import { CheckboxInput, type FeatureToggle } from '../base';

export const particle_weather: FeatureToggle = {
  name: 'Enable fancy (particle) weather (AMD GPU incompatible)',
  category: 'GAMEPLAY',
  description:
    'Enable fancy particle weather. Incompatible with AMD GPUs and will cause heavy lag on them due to a BYOND bug.',
  component: CheckboxInput,
};
