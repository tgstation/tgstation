import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const junkie: FeatureChoiced = {
  name: 'Зависимость',
  component: FeatureDropdownInput,
};

export const smoker: FeatureChoiced = {
  name: 'Любимый бренд',
  component: FeatureDropdownInput,
};

export const alcoholic: FeatureChoiced = {
  name: 'Любимый напиток',
  component: FeatureDropdownInput,
};
