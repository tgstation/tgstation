import { type Antagonist, Category } from '../base';

const Revenant: Antagonist = {
  key: 'revenant',
  name: 'Ревенант',
  description: [
    `
      Станьте таинственным ревенантом. Разбивайте окна, перегружайте свет
      и питайтесь жизненной силой экипажа, общаясь при этом со своей
      старой общиной недовольных призраков.
    `,
  ],
  category: Category.Midround,
};

export default Revenant;
