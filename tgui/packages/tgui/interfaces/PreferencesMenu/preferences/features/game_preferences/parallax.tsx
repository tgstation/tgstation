import type { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const parallax: Feature<string> = {
  name: 'Параллакс (красивый космос)',
  category: 'Геймплей',
  component: FeatureDropdownInput,
};
