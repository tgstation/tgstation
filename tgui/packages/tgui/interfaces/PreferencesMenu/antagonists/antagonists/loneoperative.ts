import { type Antagonist, Category } from '../base';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const LoneOperative: Antagonist = {
  key: 'loneoperative',
  name: 'Оперативник-одиночка',
  description: [
    `
      Шанс появления ядерного оперативника-одиночки повышается в зависимости от того,
      насколько долго диск ядерной аутентификации находится на одном месте.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default LoneOperative;
