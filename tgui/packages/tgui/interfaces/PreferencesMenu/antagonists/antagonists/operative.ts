import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

export const OPERATIVE_MECHANICAL_DESCRIPTION = multiline`
  Retrieve the nuclear authentication disk, use it to activate the nuclear
  fission explosive, and destroy the station.
`;

const Operative: Antagonist = {
  key: 'operative',
  name: 'Nuclear Operative',
  description: [
    multiline`
      Congratulations, agent. You have been chosen to join the Syndicate
      Nuclear Operative strike team. Your mission, whether or not you choose
      to accept it, is to destroy Nanotrasen's most advanced research facility!
      That's right, you're going to Space Station 13.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Operative;
