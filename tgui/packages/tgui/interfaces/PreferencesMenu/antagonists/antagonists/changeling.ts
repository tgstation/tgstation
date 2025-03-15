import { Antagonist, Category } from '../base';

export const CHANGELING_MECHANICAL_DESCRIPTION = `
Трансформируйте себя или других в другие личности и покупайте
биологическое оружие из арсенала, используя собранную вами ДНК.
`;

const Changeling: Antagonist = {
  key: 'changeling',
  name: 'Генокрад',
  description: [
    `
      Высокоинтеллектуальный инопланетный хищник, способный изменять свою
      форму, чтобы безупречно походить на человеческую.
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Changeling;
