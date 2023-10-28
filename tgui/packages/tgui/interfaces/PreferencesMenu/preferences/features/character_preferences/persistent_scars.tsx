import { CheckboxInput, FeatureToggle } from '../base';

export const persistent_scars: FeatureToggle = {
  name: 'Persistent Scars',
  description:
    'If true, scars will persist across rounds if you survive to the end. \
    They will be wiped if you are dead at roundend, however.',
  component: CheckboxInput,
};
