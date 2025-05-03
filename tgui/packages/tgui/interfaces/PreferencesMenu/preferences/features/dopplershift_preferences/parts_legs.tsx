import {
  CheckboxInput,
  Feature,
  FeatureColorInput,
  FeatureToggle,
} from '../base';

export const default_legs_color: FeatureToggle = {
  name: 'Legs Custom Color',
  description: `
    When toggled, pick a color for the legs different from the skintone.
  `,
  component: CheckboxInput,
};

export const legs_color: Feature<string> = {
  name: 'Legs Color',
  component: FeatureColorInput,
};
