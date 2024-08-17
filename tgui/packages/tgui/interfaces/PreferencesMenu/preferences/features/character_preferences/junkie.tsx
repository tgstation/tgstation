import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const junkie: FeatureChoiced = {
  name: 'Addiction',
  component: FeatureDropdownInput,
};

export const smoker: FeatureChoiced = {
  name: 'Favorite Brand',
  component: FeatureDropdownInput,
};

export const alcoholic: FeatureChoiced = {
  name: 'Favorite Drink',
  component: FeatureDropdownInput,
};
