import { FeatureTriColorInput, FeatureColorInput, Feature } from '../base';

export const frills_color: Feature<string> = {
  name: 'Frills color',
  component: FeatureColorInput,
};

export const horns_color: Feature<string> = {
  name: 'Frills color',
  component: FeatureColorInput,
};

export const feature_tricolor_alpha: Feature<string[]> = {
  name: 'Tricolor Body',
  component: FeatureTriColorInput,
};

export const feature_tricolor_beta: Feature<string[]> = {
  name: 'Tricolor Wings',
  component: FeatureTriColorInput,
};

export const feature_tricolor_charlie: Feature<string[]> = {
  name: 'Tricolor Extra',
  component: FeatureTriColorInput,
};
