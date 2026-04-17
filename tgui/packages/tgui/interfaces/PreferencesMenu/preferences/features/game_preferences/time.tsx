import { CheckboxInput, type FeatureToggle } from '../base';

export const twelve_hour: FeatureToggle = {
  name: 'Twelve-Hour Clock',
  category: 'GAMEPLAY',
  description: `
      When toggled, will replace many instances of real-world time with AM/PM instead.
    `,
  component: CheckboxInput,
};
