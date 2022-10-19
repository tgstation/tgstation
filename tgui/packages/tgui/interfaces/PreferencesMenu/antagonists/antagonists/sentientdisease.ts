import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const SentientDisease: Antagonist = {
  key: 'sentientdisease',
  name: 'Sentient Disease',
  description: [
    multiline`
      Mutate and spread yourself and infect as much of the crew as possible
      with a deadly plague of your own creation.
    `,
  ],
  category: Category.Midround,
};

export default SentientDisease;
