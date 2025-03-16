import { createDropdownInput, Feature } from '../base';

export const pixel_size: Feature<number> = {
  name: 'Масштабирование в пикселях',
  category: 'Интерфейс',
  component: createDropdownInput({
    0: 'Растягивайтесь по размеру',
    1: 'Идеальный пиксель 1x',
    1.5: 'Идеальный пиксель 1.5x',
    2: 'Идеальный пиксель 2x',
    3: 'Идеальный пиксель 3x',
    4: 'Идеальный пиксель 4x',
    4.5: 'Идеальный пиксель 4.5x',
    5: 'Идеальный пиксель 5x',
  }),
};
