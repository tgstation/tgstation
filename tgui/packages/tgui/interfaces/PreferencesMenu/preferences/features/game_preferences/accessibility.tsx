import { CheckboxInput, FeatureToggle } from '../base';

export const enable_tips: FeatureToggle = {
  name: 'Enable surgery sounds',
  category: 'ACCESSIBILITY',
  description: `
    Do you want to hear surgery sounds?
  `,
  component: CheckboxInput,
};

export const darkened_flash: FeatureToggle = {
  name: 'Enable darkened flashes',
  category: 'ACCESSIBILITY',
  description: `
    When toggled, being flashed will show a dark screen rather than a
    bright one.
  `,
  component: CheckboxInput,
};
