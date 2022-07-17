import { multiline } from 'common/string';
import { Antagonist, Category } from '../base';
import { THIEF_MECHANICAL_DESCRIPTION } from './thief';

const Opportunist: Antagonist = {
  key: 'opportunist',
  name: 'Opportunist',
  description: [
    multiline`A form of thief that can activate at any point in the middle
    of the shift, looking to line their paychecks while nobody's looking.`,
    THIEF_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Opportunist;
