import { type Antagonist, Category } from '../base';

export const CHANGELING_MECHANICAL_DESCRIPTION = `
Transform yourself or others into different identities, and buy from an
arsenal of biological weaponry with the DNA you collect.
`;

const Changeling: Antagonist = {
  key: 'changeling',
  name: 'Генокрад',
  description: [
    `
      Разумный инопланетный хищник, способный изменять свою форму,
      чтобы безупречно походить на человека.
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Changeling;
