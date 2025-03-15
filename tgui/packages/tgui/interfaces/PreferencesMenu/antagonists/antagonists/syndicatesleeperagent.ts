import { Antagonist, Category } from '../base';
import { TRAITOR_MECHANICAL_DESCRIPTION } from './traitor';

const SyndicateSleeperAgent: Antagonist = {
  key: 'syndicatesleeperagent',
  name: 'Тайный агент Синдиката',
  description: [
    `
      Разновидность предателя, которая может активироваться в любой момент в середине
      смены.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default SyndicateSleeperAgent;
