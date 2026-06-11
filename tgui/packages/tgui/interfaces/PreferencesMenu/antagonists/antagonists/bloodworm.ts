import { type Antagonist, Category } from '../base';

const BloodWorm: Antagonist = {
  key: 'bloodworm',
  name: 'Blood Worm',
  description: [
    `
      Become a giant, parasitic blood worm. Start as a hatchling in a host,
      consume blood and conquer the entire station alongside your siblings!
    `,
  ],
  category: Category.Roundstart,
};

export default BloodWorm;
