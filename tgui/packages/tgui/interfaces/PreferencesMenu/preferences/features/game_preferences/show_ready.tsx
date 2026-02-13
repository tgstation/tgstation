import { CheckboxInput, type FeatureToggle } from '../base';

export const ready_job: FeatureToggle = {
  name: 'Show Ready Job In Lobby',
  category: 'GAMEPLAY',
  description:
    'Adds your highest preferred Job to a tally when you are readied up in the lobby.',
  component: CheckboxInput,
};
