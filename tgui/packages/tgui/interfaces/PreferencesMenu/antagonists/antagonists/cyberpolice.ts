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
    Compile into the virtual domain as a Cyber Policeman. Use your refined
    combat skills and quick reflexes to hunt down and eliminate unauthorized
    code execution. Terminate rogue programs. Look stylish while doing it.
    `,
  ],
  category: Category.Midround,
};

export default CyberPolice;
