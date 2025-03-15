import { Antagonist, Category } from '../base';
import { HERETIC_MECHANICAL_DESCRIPTION } from './heretic';

const HereticSmuggler: Antagonist = {
  key: 'hereticsmuggler',
  name: 'Еретик',
  description: [
    'Разновидность еретика, которая может активироваться при присоединении к текущей смене.',
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Latejoin,
};

export default HereticSmuggler;
