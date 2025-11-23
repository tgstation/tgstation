import { CheckboxInputInverse, type FeatureToggle } from '../base';

export const hotkeys: FeatureToggle = {
  name: 'Classic hotkeys',
  category: 'GAMEPLAY',
  description:
    'When enabled, will revert to the legacy hotkeys, using the input bar rather than popups.',
  component: CheckboxInputInverse,
};
