import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { CHANGELING_MECHANICAL_DESCRIPTION } from './changeling';

const Stowaway_Changeling: Antagonist = {
  key: 'stowawaychangeling',
  name: 'Stowaway Changeling',
  description: [
    multiline`
      A Changeling that found its way onto the shuttle
      unbeknownst to the crewmembers on board.
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Latejoin,
};

export default Stowaway_Changeling;
