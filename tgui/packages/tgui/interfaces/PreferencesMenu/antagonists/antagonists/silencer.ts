import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Silencer: Antagonist = {
  key: 'silencer',
  name: 'Silencer',
  description: [
    multiline`
      Too much noise, too much noise! The station must be silenced.
      Collect at least half of the station's tongues. Yes, that should do it.
    `,
  ],
  category: Category.Roundstart,
};

export default Silencer;
