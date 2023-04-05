import { CheckboxInput, FeatureToggle } from '../base';

export const context_menu_requires_shift: FeatureToggle = {
  name: 'Context Menu On Shift Click',
  category: 'GAMEPLAY',
  description: 'Require holding shift to open the context menu.',
  component: CheckboxInput,
};
