import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const VoidSentinel: Antagonist = {
  key: 'voidsentinel',
  name: 'Void Sentinel',
  description: [
    multiline`
    On the razor edge of the digital realm, the Cyber Authority has tasked
    Void Sentinels with preserving system harmony.
    `,

    multiline`
    Embrace the role of a Void Sentinel, a figure of authority within the virtual
    domain. Use your refined combat skills and quick reflexes to hunt down and
    eliminate unauthorized code execution.
    `,
  ],
  category: Category.Midround,
};

export default VoidSentinel;
