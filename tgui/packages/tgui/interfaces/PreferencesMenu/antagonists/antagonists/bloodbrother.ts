import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const BloodBrother: Antagonist = {
  key: 'bloodbrother',
  name: 'Blood Brother',
  description: [
    multiline`
      Team up with other crew members as blood brothers to combine the strengths
      of your departments, break each other out of prison, and overwhelm the
      station.
    `,
  ],
  category: Category.Roundstart,
};

export default BloodBrother;
