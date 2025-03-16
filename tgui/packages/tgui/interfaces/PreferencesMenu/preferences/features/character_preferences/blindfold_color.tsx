import { Feature, FeatureColorInput } from '../base';

export const blindfold_color: Feature<string> = {
  name: 'Цвет повязки на глазах',
  component: FeatureColorInput,
};
