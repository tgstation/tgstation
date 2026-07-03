import { type Feature, FeatureColorInput } from '../base';

export const paint_color: Feature<string> = {
  name: 'Цвет краски в баллончике',
  component: FeatureColorInput,
};
