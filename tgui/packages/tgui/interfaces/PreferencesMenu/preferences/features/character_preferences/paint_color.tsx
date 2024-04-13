import { Feature, FeatureColorInput } from '../base';

export const paint_color: Feature<string> = {
  name: 'Spray paint color',
  component: FeatureColorInput,
};
