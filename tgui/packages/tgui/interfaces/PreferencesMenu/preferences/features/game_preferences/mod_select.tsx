import type { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const mod_select: Feature<string> = {
  name: 'MOD active module key',
  category: 'GAMEPLAY',
  description: 'The key you need to use an active MODsuit module.',
  component: FeatureDropdownInput,
};
