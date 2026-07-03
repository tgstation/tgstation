import { createDropdownInput, type Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Мульти-Z - детализация',
  category: 'Геймплей',
  description: 'Уровень детализации мульти-Z. Влияет на производительность.',
  component: createDropdownInput({
    [-1]: 'Стандартная',
    2: 'Высокая',
    1: 'Средняя',
    0: 'Низкая',
  }),
};
