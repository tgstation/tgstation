import { type Antagonist, Category } from '../base';

const FlockAgent: Antagonist = {
  key: 'flockagent',
  name: 'Flock Agent',
  description: [
    `
      Run around the station and grab what's not nailed down.
      Give people a reason to dread the existence of intercoms.
    `,
  ],
  category: Category.Midround,
};

export default FlockAgent;
