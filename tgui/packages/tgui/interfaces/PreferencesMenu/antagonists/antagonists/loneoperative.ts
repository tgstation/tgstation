import { Antagonist, Category } from '../base';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const LoneOperative: Antagonist = {
  key: 'loneoperative',
  name: 'Оперативник-одиночка',
  description: [
    `
      Одиночный ядерный агент, у которого тем больше шансов появиться на свет, чем дольше
      диск с ядерной аутентификацией остается на одном месте.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default LoneOperative;
