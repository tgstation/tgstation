import { Antagonist, Category } from '../base';

const Fugitive: Antagonist = {
  key: 'fugitive',
  name: 'Беглец',
  description: [
    `
      Откуда бы вы ни пришли, за вами охотятся. У вас есть 10 минут, чтобы подготовиться,
      прежде чем появятся охотники за беглецами и начнут охоту на вас и ваших друзей!
    `,
  ],
  category: Category.Midround,
};

export default Fugitive;
