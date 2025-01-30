import {
  CheckboxInput,
  Feature,
  FeatureToggle,
  FeatureTriColorInput,
} from '../base';

export const has_breasts: FeatureToggle = {
  name: 'Add Part: Breasts',
  category: 'GAMEPLAY',
  description: `
    When toggled, adds breasts to your character.
  `,
  component: CheckboxInput,
};

export const breasts_color: Feature<string[]> = {
  name: 'Breasts Color',
  component: FeatureTriColorInput,
};
