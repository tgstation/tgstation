import { type Antagonist, Category } from '../base';

const BloodWormInfestation: Antagonist = {
  key: 'bloodworminfestation',
  name: 'Заражение кровяным червём',
  description: [
    `
      Стань гигантским паразитическим кровяным червём. Начав жизнь личинкой в теле носителя,
      питайтесь кровью и вместе со своими сородичами покорите всю станцию!
    `,
  ],
  category: Category.Midround,
};

export default BloodWormInfestation;
