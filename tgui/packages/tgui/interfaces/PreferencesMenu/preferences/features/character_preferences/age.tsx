import { type Feature, FeatureSliderInput } from '../base';

export const age: Feature<number> = {
  name: 'Возраст',
  component: FeatureSliderInput,
};
