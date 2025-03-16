import { createDropdownInput, Feature } from '../base';

export const scaling_method: Feature<string> = {
  name: 'Способ масштабирования',
  category: 'Интерфейс',
  component: createDropdownInput({
    blur: 'Билинейный',
    distort: 'Ближайшего соседа',
    normal: 'Точечный отбор проб',
  }),
};
