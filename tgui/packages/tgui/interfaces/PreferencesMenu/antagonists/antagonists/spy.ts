import { type Antagonist, Category } from '../base';

const Spy: Antagonist = {
  key: 'spy',
  name: 'Spy',
  description: [
    `
      Your mission, should you choose to accept it: Infiltrate Space Station 13.
      Disguise yourself as a member of their crew and steal vital equipment.
      Should you be caught or killed, your employer will disavow any knowledge
      of your actions. Good luck agent.
    `,

    `
      Complete Spy Bounties to earn rewards from your employer.
      Use these rewards to sow chaos and mischief!
    `,
  ],
  category: Category.Roundstart,
};

export default Spy;
