import { FeatureTriColorInput, FeatureColorInput, Feature, CheckboxInput, FeatureToggle } from '../base';

export const penis_color: Feature<string[]> = {
  name: 'Penis Color',
  component: FeatureTriColorInput,
};

export const testicles_color: Feature<string[]> = {
  name: 'Testicles Color',
  component: FeatureTriColorInput,
};

export const vagina_color: Feature<string[]> = {
  name: 'Vagina Color',
  component: FeatureTriColorInput,
};

export const has_breasts: FeatureToggle = {
  name: 'Add Breasts',
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