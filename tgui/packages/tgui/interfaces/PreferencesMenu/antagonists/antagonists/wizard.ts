import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

export const WIZARD_MECHANICAL_DESCRIPTION = multiline`
      Choose between a variety of powerful spells in order to cause chaos
      among Space Station 13.
    `;

const Wizard: Antagonist = {
  key: 'wizard',
  name: 'Wizard',
  description: [
    `"GREETINGS. WE'RE THE WIZARDS OF THE WIZARD'S FEDERATION."`,
    WIZARD_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Wizard;
