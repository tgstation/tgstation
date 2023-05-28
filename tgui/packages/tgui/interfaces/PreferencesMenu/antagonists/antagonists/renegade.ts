import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Renegade: Antagonist = {
  key: 'renegade',
  name: 'Renegade',
  description: [
    multiline`
    You're paranoid about your surroundings and co-workers!
    Are they planning to kill you? You cannot trust anybody.
    No matter how it is, you know - YOU MUST SURVIVE BY ANY MEANS POSSIBLE.
    `,
  ],
  category: Category.Midround,
};

export default Renegade;
