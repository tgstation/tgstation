import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const StoryParticipant: Antagonist = {
  key: 'storyparticipant',
  name: 'Story Participant',
  description: [
    multiline`
    Participate in a variety of interesting stories designed to create conflict
    and chaos aboard Space Station 13!
	  `,

    multiline`
		This is a blanket non-antagonist preference, including roles like
    Central Command inspectors, smugglers, mobsters, artists, authors, agents,
    tourists, management, and more!
	  `,
  ],
  category: Category.Roundstart,
};

export default StoryParticipant;
