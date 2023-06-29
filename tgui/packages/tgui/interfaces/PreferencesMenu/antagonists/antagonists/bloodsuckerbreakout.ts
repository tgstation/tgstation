import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const BloodsuckerBreakout: Antagonist = {
  key: 'bloodsuckerbreakout',
  name: 'Bloodsucker (Latejoin)',
  description: [
    multiline`
      After your death, you awaken to see yourself as an undead monster.
      Use your Vampiric abilities as best you can.
      Scrape by Space Station 13, or take over it, vassalizing your way.
    `,
  ],
  category: Category.Latejoin,
};

export default BloodsuckerBreakout;
