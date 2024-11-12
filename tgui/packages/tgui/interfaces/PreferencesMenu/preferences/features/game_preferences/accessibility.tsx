import { CheckboxInput, FeatureToggle } from '../base';

export const darkened_flash: FeatureToggle = {
  name: 'Enable darkened flashes',
  category: 'ACCESSIBILITY',
  description: `
    When toggled, being flashed will show a dark screen rather than a
    bright one.
  `,
  component: CheckboxInput,
};

export const screen_shake_darken: FeatureToggle = {
  name: 'Darken screen shake',
  category: 'ACCESSIBILITY',
  description: `
      When toggled, experiencing screen shake will darken your screen.
    `,
  component: CheckboxInput,
};
