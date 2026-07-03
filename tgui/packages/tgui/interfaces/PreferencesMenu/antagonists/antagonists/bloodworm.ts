import { type Antagonist, Category } from '../base';

const BloodWorm: Antagonist = {
  key: 'bloodworm',
  name: 'Кровяной червь',
  description: [
    `
      Стань гигантским паразитическим кровяным червём. Начав жизнь личинкой в теле носителя,
      питайтесь кровью и вместе со своими сородичами покорите всю станцию!
    `,
  ],
  category: Category.Roundstart,
};

export default BloodWorm;
