import { type Antagonist, Category } from '../base';
import { CHANGELING_MECHANICAL_DESCRIPTION } from './changeling';

const ChangelingMidround: Antagonist = {
  key: 'changelingmidround',
  name: 'Генокрад с космоса',
  description: [
    `
    Вариант генокрада, который не получает личность экипажа, а прибывает
    из космоса во время смены. Эта версия сложнее, чем начинающаяся в начале смены!
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default ChangelingMidround;
