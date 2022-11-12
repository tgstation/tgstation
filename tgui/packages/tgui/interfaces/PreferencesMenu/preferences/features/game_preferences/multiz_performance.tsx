import { createDropdownInput, Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Multiz Rendering Resolution',
  category: 'GAMEPLAY',
  description:
  'How many z levels of multiz to render normally before switching to a less intensive rendering mode',
  component: createDropdownInput({
    [-1]: 'Disable',
    0: 'Zero',
    1: 'One',
    2: 'Two',
    3: 'Three',
  }),
};
