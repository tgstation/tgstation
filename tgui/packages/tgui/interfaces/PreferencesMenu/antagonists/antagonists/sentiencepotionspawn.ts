import { Antagonist, Category } from '../base';

const SentientCreature: Antagonist = {
  key: 'sentiencepotionspawn',
  name: 'Sentient Creature',
  description: [
    `
		Either by cosmic happenstance, or due to crew's shenanigans, you have been
		given sentience!
	  `,

    `
		This is a blanket preference. The more benign ones include random human
		level intelligence events, the cargorilla, and creatures uplifted via sentience
		potions. The less friendly ones include the regal rat, and the boosted
		mining elite mobs.
	  `,
  ],
  category: Category.Midround,
};

export default SentientCreature;
