import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Glitch: Antagonist = {
  key: 'glitch',
  name: 'Glitch',
  description: [
    multiline`
    The virtual domain is a dangerous place for bitrunners. Make it so.
    `,

    multiline`
    You are a short-term antagonist, a glitch in the system. Use martial arts \
    and lethal weaponry to terminate organics.
    `,
  ],
  category: Category.Midround,
};

export default Glitch;
