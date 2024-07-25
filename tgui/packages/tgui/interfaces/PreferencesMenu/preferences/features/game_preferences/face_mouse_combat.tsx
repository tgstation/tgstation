import { CheckboxInput, FeatureToggle } from '../base';

export const face_cursor_combat_mode: FeatureToggle = {
  name: 'Face mouse in combat mode',
  category: 'GAMEPLAY',
  description:
    'If your character should face towards your cursor while in combat mode.',
  component: CheckboxInput,
};
