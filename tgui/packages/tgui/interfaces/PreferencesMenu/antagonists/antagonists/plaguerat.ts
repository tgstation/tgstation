import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const PlagueRat: Antagonist = {
  key: 'plaguerat',
  name: 'Plague Rat',
  description: [
    multiline`
    You are a rat that spreads the plague.
    Also wish micheal a happy birthday.
    `,
  ],
  category: Category.Midround,
};

export default PlagueRat;
