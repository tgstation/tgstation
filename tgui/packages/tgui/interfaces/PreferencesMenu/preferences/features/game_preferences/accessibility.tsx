import { CheckboxInput, type Feature, type FeatureToggle, FeatureSliderInput } from '../base';

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

export const remove_double_click: FeatureToggle = {
  name: 'Remove double click',
  category: 'ACCESSIBILITY',
  description: `
      When toggled, actions that require a double click will instead offer
      alternatives, good if you have a not-so-functional mouse.
    `,
  component: CheckboxInput,
};

export const min_recoil_multiplier: Feature<number> = {
  name: 'Cosmetic Recoil Multiplier',
  category: 'ACCESSIBILITY',
  description: `
      A percentage for how much the small minimum recoil of weapons affects you.
      0 will remove it entirely, but this does not affect the base recoil that is used for balance.
    `,
  component: FeatureSliderInput,
};
