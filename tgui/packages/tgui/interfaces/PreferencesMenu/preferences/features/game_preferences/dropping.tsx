import { CheckboxInput, type FeatureToggle } from '../base';

export const specific_dropping: FeatureToggle = {
  name: 'Precise Dropping',
  category: 'GAMEPLAY',
  description:
    'The drop hotkey go to where your cursor is (similar to SS14), rather than under the player.',
  component: CheckboxInput,
};
