import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const FloridaMan: Antagonist = {
  key: 'floridaman',
  name: 'Florida Man',
  description: [
    multiline`
    You are the bane of doors everywhere, and can push through them with ease.
    Crash on the station in a broken-down car and questionable clothing choices.
    Cause chaos.
    `,

    multiline`
    Florida Man does as Florida Man wants. Hailing from the proud state of
    Space Florida, you have come to the station to spread the glorious culture
    of your home. Complete whatever your stoned and questionably coherent
    Florida Men superiors have written down for you... or don't.
    Who gets to boss Florida Man around anyways?
    `,
  ],
  category: Category.Midround,
};

export default FloridaMan;
