import { Feature, FeatureColorInput } from '../base';

export const paint_color: Feature<string> = {
  name: 'Spray paint color',
  description: 'The default color of the paint spray can you start with.',
  component: FeatureColorInput,
};
