import { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const prisoner_crime: FeatureChoiced = {
  name: 'Преступление заключенного',
  description:
    'Когда вы окажетесь в заключении, это будет внесено в ваши досье в качестве причины вашего ареста.',
  component: FeatureDropdownInput,
};
