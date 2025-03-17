import { Antagonist, Category } from '../base';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const OperativeMidround: Antagonist = {
  key: 'operativemidround',
  name: 'Ядерный оперативник',
  description: [
    `
      Разновидность ядерного оперативника, которое предлагается призракам в середине
      смены.
    `,
    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default OperativeMidround;
