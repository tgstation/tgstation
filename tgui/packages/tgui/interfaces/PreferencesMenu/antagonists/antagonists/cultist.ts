import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Cultist: Antagonist = {
  key: 'cultist',
  name: 'Cultist',
  description: [
    multiline`
      The Geometer of Blood, Nar-Sie, has sent a number of her followers to
      Space Station 13. As a cultist, you have an abundance of cult magics at
      your disposal, something for all situations. You must work with your
      brethren to summon an avatar of your eldritch goddess!
    `,

    multiline`
      Armed with blood magic, convert crew members to the Blood Cult, sacrifice
      those who get in the way, and summon Nar-Sie.
    `,
  ],
  category: Category.Roundstart,
};

export default Cultist;
