import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const FrogressionTraitor: Antagonist = {
  key: 'frogressiontraitor',
  name: 'Frogression Traitor',
  description: [
    multiline`
    The long-ranged mindswap experiment was supposed to put you in the
    body of a high-ranking Nanotrasen employee. It would seem that it wasn't
    as reliable as they had promised you... Nevertheless you will just
    have to make due until you can be extracted.
    `,
  ],
  category: Category.Midround,
};

export default FrogressionTraitor;
