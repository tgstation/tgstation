import { Antagonist, Category } from '../base';

export const OPERATIVE_MECHANICAL_DESCRIPTION = `
  Attain all possible GoldenEye authentication keys and use them to activate
  the GoldenEye. These keys use mindfragments of Nanotrasen heads to generate
  the key. Use the interrogator to extract these mindfragments.
`;

const AssaultOperative: Antagonist = {
  key: 'assaultoperative',
  name: 'Assault Operative',
  description: [
    `
      Good afternoon 0013, you have been selected to join an elite strike team
      designated to locating and forging GoldenEye keys. Your mission is to
      get these keys and use them to turn Nanotrasens GoldenEye defence
      network against them. The GoldenEye network requires 3 keys to activate.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default AssaultOperative;
