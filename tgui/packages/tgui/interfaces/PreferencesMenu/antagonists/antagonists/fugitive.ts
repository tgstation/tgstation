import { multiline } from 'common/string';

import { Antagonist, Category } from '../base';

const Fugitive: Antagonist = {
  key: 'fugitive',
  name: 'Fugitive',
  description: [
    multiline`
    Wherever you come from, you're being hunted. You have 10 minutes to prepare
    before fugitive hunters arrive and start hunting you and your friends down!
    `,
  ],
  category: Category.Midround,
};

export default Fugitive;
