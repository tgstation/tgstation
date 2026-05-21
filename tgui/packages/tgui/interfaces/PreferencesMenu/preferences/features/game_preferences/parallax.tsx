import type { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const parallax: Feature<string> = {
  name: 'Parallax (fancy space)',
  category: 'GAMEPLAY',
  component: FeatureDropdownInput,
};
