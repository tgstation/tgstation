import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const CyberPolice: Antagonist = {
  key: 'cyberpolice',
  name: 'Cyber Police',
  description: [
    multiline`
    On the razor edge of the digital realm, the Cyber Authority has tasked
    enforcement officers with preserving system harmony.
    `,

    multiline`
    Using refined martial arts skills, terminate bitrunners in the virtual
    domain. Look snazzy while doing it. Cyber police are short lived combat
    roles that spawn from mobs (other than elites or players) in the virtual
    domain.
    `,
  ],
  category: Category.Midround,
};

export default CyberPolice;
