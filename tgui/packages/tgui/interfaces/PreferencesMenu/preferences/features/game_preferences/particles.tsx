import { CheckboxInput, FeatureToggle } from '../base';

export const particles: FeatureToggle = {
  name: 'Render particles',
  category: 'GAMEPLAY',
  description: 'Disable to not render most particles, can help with frames.',
  component: CheckboxInput,
};
