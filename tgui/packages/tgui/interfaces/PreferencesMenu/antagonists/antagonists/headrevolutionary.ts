import { type Antagonist, Category } from '../base';

export const REVOLUTIONARY_MECHANICAL_DESCRIPTION = `
      Вооружившись флэшем, обратите в революцию как можно больше людей.
      Убейте или изгоните всех глав станции.
   `;

const HeadRevolutionary: Antagonist = {
  key: 'headrevolutionary',
  name: 'Глава революции',
  description: ['VIVA LA REVOLUTION!', REVOLUTIONARY_MECHANICAL_DESCRIPTION],
  category: Category.Roundstart,
};

export default HeadRevolutionary;
