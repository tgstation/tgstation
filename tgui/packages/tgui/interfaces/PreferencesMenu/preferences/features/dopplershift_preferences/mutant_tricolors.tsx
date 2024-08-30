import { FeatureTriColorInput, FeatureColorInput, Feature } from '../base';

export const snout_color: Feature<string[]> = {
  name: 'Snout Color',
  component: FeatureTriColorInput,
};