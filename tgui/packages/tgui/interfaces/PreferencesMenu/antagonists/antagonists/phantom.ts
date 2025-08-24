import { type Antagonist, Category } from '../base';

const Phantom: Antagonist = {
  key: 'phantom',
  name: 'Phantom',
  description: [
    `
      Become the mysterious phantom. Break windows, overload lights, and eat
      the crew's life force, all while talking to your old community of
      disgruntled ghosts.
    `,
  ],
  category: Category.Midround,
};

export default Phantom;
