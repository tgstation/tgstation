import { type Antagonist, Category } from '../base';

export const TRAITOR_MECHANICAL_DESCRIPTION = `
      Start with an uplink to purchase your gear and take on your sinister
      objectives. Ascend through the ranks and become an infamous legend.
   `;

const Traitor: Antagonist = {
  key: 'traitor',
  name: 'Traitor',
  description: [
    `
      An unpaid debt. A score to be settled. Maybe you were just in the wrong
      place at the wrong time. Whatever the reasons, you were selected to
      infiltrate Space Station 13.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Traitor;
