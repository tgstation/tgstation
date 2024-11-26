import { Antagonist, Category } from '../base';
import { CHANGELING_MECHANICAL_DESCRIPTION } from './changeling';

const ChangelingMidround: Antagonist = {
  key: 'changelingmidround',
  name: 'Space Changeling',
  description: [
    `
    A midround changeling does not receive a crew identity, instead arriving
    from space. This will be more difficult than being a round-start changeling!
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default ChangelingMidround;
