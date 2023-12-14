import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const TigerFanatic: Antagonist = {
  key: 'tigerfanatic',
  name: 'Tiger Cooperative Fanatic',
  description: [
    multiline`
      Praise the shapeshifters! You have completed holy pilgrimage to
      space station 13, beckoned by the whispers of the changeling hive!
      Worship your idols, and perhaps you can become one with the changeling
      hive!
    `,

    multiline`
      Worship the changelings, play the perfect evil minion!
      Coordinate with your idols by speaking in hive chat.
      Changeling abilities have additional effects on you.
      Receive their blessings.
    `,
  ],
  category: Category.Midround,
};

export default TigerFanatic;
