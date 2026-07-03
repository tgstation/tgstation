import type { FeatureChoiced } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const prisoner_crime: FeatureChoiced = {
  name: 'Преступления заключенного',
  description:
    'Будучи заключенным, эта информация будет внесена в ваши записи как причина вашего ареста.',
  component: FeatureDropdownInput,
};
