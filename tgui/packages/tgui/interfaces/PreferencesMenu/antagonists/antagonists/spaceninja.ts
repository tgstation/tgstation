import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const SpaceNinja: Antagonist = {
  key: 'spaceninja',
  name: 'Space Ninja',
  description: [
    multiline`
      The Spider Clan practice a sort of augmentation of human flesh in order to
      achieve a more perfect state of being and follow Postmodern Space Bushido.
    `,

    multiline`
      Become a conniving space ninja, equipped with a katana, gloves to hack
      into airlocks and APCs, a suit to make you go near-invisible,
      as well as a variety of abilities in your kit. Hack into arrest consoles
      to mark everyone as arrest, and even hack into communication consoles to
      summon more threats to cause chaos on the station!
    `,
  ],
  category: Category.Midround,
};

export default SpaceNinja;
