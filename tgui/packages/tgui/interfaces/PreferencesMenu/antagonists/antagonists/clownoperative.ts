import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const ClownOperative: Antagonist = {
  key: 'clownoperative',
  name: 'Clown Operative',
  description: [
    multiline`
      Honk! You have been chosen, for better or worse to join the Syndicate
      Clown Operative strike team. Your mission, whether or not you choose
      to tickle it, is to honk Nanotrasen's most advanced research facility!
      That's right, you're going to Clown Station 13.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default ClownOperative;
