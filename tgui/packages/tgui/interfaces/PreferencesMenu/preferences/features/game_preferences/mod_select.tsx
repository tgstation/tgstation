import { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const mod_select: Feature<string> = {
  name: 'Клавиша активного модуля MOD',
  category: 'Гемплей',
  description: 'Ключ, необходимый для использования активного модуля MODsuit.',
  component: FeatureDropdownInput,
};
