import { multiline } from 'common/string';
import { Antagonist, Category } from '../base';

const DriftingContractor: Antagonist = {
  key: 'driftingcontractor',
  name: 'Drifting Contractor',
  description: [
    multiline`A Syndicate agent that can spawn near the station, equipped with
    top-of-the-line contractor gear, to complete contracts for the Syndicate.`,
    multiline`Float onto the station and complete as many
    contracts for your employer as you can!`,
  ],
  category: Category.Midround,
};

export default DriftingContractor;
