import { Antagonist, Category } from '../base';

const Revenant: Antagonist = {
  key: 'revenant',
  name: 'Ревенант',
  description: [
    `
      Станьте таинственным призраком. Разбивайте окна, отключайте освещение и питайтесь
      жизненной силой экипажа, и все это время общайтесь со своим старым сообществом
      недовольных призраков.
    `,
  ],
  category: Category.Midround,
};

export default Revenant;
