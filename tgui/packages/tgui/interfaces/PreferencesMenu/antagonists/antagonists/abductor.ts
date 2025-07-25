import { type Antagonist, Category } from '../base';

const Abductor: Antagonist = {
  key: 'abductor',
  name: 'Abductor',
  description: [
    `
      Abductors are technologically advanced alien society set on cataloging
      all species in the system. Unfortunately for their subjects their methods
      are quite invasive.
    `,

    `
      You and a partner will become the abductor scientist and agent duo.
      As an agent, abduct unassuming victims and bring them back to your UFO.
      As a scientist, scout out victims for your agent, keep them safe, and
      operate on whoever they bring back.
    `,
  ],
  category: Category.Midround,
};

export default Abductor;
