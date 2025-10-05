import { type Antagonist, Category } from '../base';

export const HERETIC_MECHANICAL_DESCRIPTION = `
      Find hidden influences and sacrifice crew members to gain magical
      powers and ascend as one of several paths.
   `;

const Heretic: Antagonist = {
  key: 'heretic',
  name: 'Heretic',
  description: [
    `
      Forgotten, devoured, gutted. Humanity has forgotten the eldritch forces
      of decay, but the mansus veil has weakened. We will make them taste fear
      again...
    `,
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Heretic;
