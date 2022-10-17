import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const SentientCreature: Antagonist = {
  key: 'sentiencepotionspawn',
  name: 'Sentient Creature',
  description: [
    multiline`
		Either by cosmic happenstance, or due to crew's shenanigans, you have been
		given sentience!
	  `,

    multiline`
		This is a blanket preference. The more benign ones include random human 
		level intelligence events, the cargorilla, and creatures uplifted via sentience 
		potions. The less friendly ones include the regal rat, and the boosted 
		mining elite mobs.
	  `,
  ],
  category: Category.Midround,
};

export default SentientCreature;
