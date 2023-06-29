import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const MonsterHunter: Antagonist = {
  key: 'monsterhunter',
  name: 'Monster Hunter',
  description: [
    multiline`
      Quitting retirement due to an increase of Monsters on station,
      Monster Hunters are humans out for the kill on the monstrous activities
      on board Space Station 13. Prepared with stakes and Martial arts,
      these expert Hunters will stop at nothing to kill their prey.
    `,
  ],
  category: Category.Midround,
};

export default MonsterHunter;
