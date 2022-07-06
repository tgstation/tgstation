import { Antagonist, Category } from '../base';
import { WIZARD_MECHANICAL_DESCRIPTION } from './wizard';

const WizardMidround: Antagonist = {
  key: 'wizardmidround',
  name: 'Wizard (Midround)',
  description: [
    'A form of wizard that is offered to ghosts in the middle of the shift.',
    WIZARD_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default WizardMidround;
