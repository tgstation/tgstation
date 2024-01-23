import { CheckboxInput, FeatureToggle } from '../base';

export const prude_mode: FeatureToggle = {
  name: 'Enable Prude Mode',
  category: 'GAMEPLAY',
  description:
    'Wont hear fart noises or see fart messages, urine is named to ammonia.',
  component: CheckboxInput,
};
