import { type Antagonist, Category } from '../base';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const ClownoOperativeMidround: Antagonist = {
  key: 'clownoperativemidround',
  name: 'Clown Ass-ailant',
  description: [
    `
     A form of clown operative that is offered to ghosts in the middle
     of the shift.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default ClownoOperativeMidround;
