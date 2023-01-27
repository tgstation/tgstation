import { createDropdownInput, Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Multi-Z Detail',
  category: 'GAMEPLAY',
  description: 'How detailed multi-z is. Lower this to improve performance',
  component: createDropdownInput({
    [-1]: 'Standard',
    3: 'High',
    2: 'Medium',
    1: 'Low',
    0: 'Minimal',
  }),
};
