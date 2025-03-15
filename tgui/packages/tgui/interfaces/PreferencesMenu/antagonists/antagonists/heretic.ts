import { Antagonist, Category } from '../base';

export const HERETIC_MECHANICAL_DESCRIPTION = `
      Найдите скрытые источники влияния и принесите в жертву членов экипажа, чтобы обрести магическую
      силу и подняться по одному из нескольких путей.
  `;

const Heretic: Antagonist = {
  key: 'heretic',
  name: 'Еретик',
  description: [
    `
      Забытые, поглощенные, выпотрошенные. Человечество забыло о сверхъестественных силах
      разложения, но завеса человека ослабла. Мы заставим их снова почувствовать вкус страха...
    `,
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Heretic;
