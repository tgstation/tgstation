import { CheckboxInput, type FeatureToggle } from '../base';

export const hide_roundend_ckey: FeatureToggle = {
  name: 'Hide roundend report ckey',
  category: 'GAMEPLAY',
  description: 'When enabled, your ckey will be hidden in the roundend report.',
  component: CheckboxInput,
};
