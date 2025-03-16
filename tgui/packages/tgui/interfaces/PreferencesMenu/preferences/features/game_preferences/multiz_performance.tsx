import { createDropdownInput, Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Многоугольная деталь',
  category: 'Гемплей',
  description:
    'Насколько детализирован параметр multi-z. Уменьшите это значение для повышения производительности',
  component: createDropdownInput({
    [-1]: 'Стандарт',
    2: 'Высокий',
    1: 'Средний',
    0: 'Низкий',
  }),
};
