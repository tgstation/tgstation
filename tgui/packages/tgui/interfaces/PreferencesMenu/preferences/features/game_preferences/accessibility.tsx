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
  name: 'Cosmetic Recoil Strength',
  category: 'ACCESSIBILITY',
  description: `
      Modifies the strength of cosmetic recoil's effect on your camera.
      0 will disable cosmetic recoil entirely, though mechanical recoil will be unaffected.
    `,
  component: FeatureSliderInput,
};

export const stair_indicator: FeatureToggle = {
  name: 'Enable stair indicator',
  category: 'ACCESSIBILITY',
  description: `
      When toggled, staircases will have a visual indicator showing which
      direction to walk to transition floors.
    `,
  component: CheckboxInput,
};
