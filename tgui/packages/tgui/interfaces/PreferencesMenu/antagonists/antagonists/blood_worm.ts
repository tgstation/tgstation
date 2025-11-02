import { type Antagonist, Category } from '../base';

const BloodWorm: Antagonist = {
  key: 'bloodworm',
  name: 'Blood Worm',
  description: [
    `
      Become a giant, parasitic blood worm. Start as a hatchling, take hosts,
      consume blood and conquer the entire station alongside your siblings!
    `,
  ],
  category: Category.Midround,
};

export default BloodWorm;
