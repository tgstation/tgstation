import { type Antagonist, Category } from '../base';

const Obsessed: Antagonist = {
  key: 'obsessed',
  name: 'Obsessed',
  description: [
    `
    You're obsessed with someone! Your obsession may begin to notice their
    personal items are stolen and their coworkers have gone missing,
    but will they realize they are your next victim in time?
    `,
  ],
  category: Category.Midround,
};

export default Obsessed;
