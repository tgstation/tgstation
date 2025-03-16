import { Feature, FeatureColorInput } from '../base';

export const paint_color: Feature<string> = {
  name: 'Цвет аэрозольной краски',
  component: FeatureColorInput,
};
