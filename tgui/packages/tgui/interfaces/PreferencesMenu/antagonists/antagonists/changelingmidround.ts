import { Antagonist, Category } from '../base';
import { CHANGELING_MECHANICAL_DESCRIPTION } from './changeling';

const ChangelingMidround: Antagonist = {
  key: 'changelingmidround',
  name: 'Космический генокрад',
  description: [
    `
      Подменыш среднего уровня не получает удостоверение члена экипажа, вместо этого он прибывает
      из космоса. Это будет сложнее, чем быть подменышем среднего уровня!
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default ChangelingMidround;
