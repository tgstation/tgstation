import { createDropdownInput, type Feature } from '../base';

export const pixel_size: Feature<number> = {
  name: 'Pixel Scaling',
  category: 'UI',
  component: createDropdownInput({
    0: 'Stretch to fit',
    1: 'Pixel Perfect 1x',
    1.5: 'Pixel Perfect 1.5x',
    2: 'Pixel Perfect 2x',
    3: 'Pixel Perfect 3x',
    4: 'Pixel Perfect 4x',
    4.5: 'Pixel Perfect 4.5x',
    5: 'Pixel Perfect 5x',
    6: 'Pixel Perfect 6x',
    7: 'Pixel Perfect 7x',
    8: 'Pixel Perfect 8x',
    9: 'Pixel Perfect 9x',
  }),
};
