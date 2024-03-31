import { multiline } from 'common/string';

import { Antagonist, Category } from '../base';

const Axototl: Antagonist = {
  key: 'axototl',
  name: 'Axototl',
  description: [
    multiline`
    Axototls are axolotls that have been bribed, coerced or otherwise
    driven to betray their station by the Syndicate.
    `,
  ],
  category: Category.Midround,
};

export default Axototl;
