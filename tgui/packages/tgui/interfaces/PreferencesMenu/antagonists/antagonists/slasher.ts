import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Slasher: Antagonist = {
  key: 'slasher',
  name: 'Slasher',
  description: [
    multiline`
    Terrorize the station with an expressionless mask and recallable machete.
    Use the shadows to stalk your victims. Spread gore everywhere.
    `,

    multiline`
    No matter your tragic origin, you look as if you've just walked from the set
    of an 80's slasher film to a space station of the future. Your spooky aura
    remains unmatched by even the most daunting of maintenance clowns.
    Give the station something to fear.
    `,
  ],
  category: Category.Midround,
};

export default Slasher;
