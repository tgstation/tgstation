import { CheckboxInput, type FeatureToggle } from '../base';

export const persistent_scars: FeatureToggle = {
  name: 'Persistent Scars',
  description:
    'If checked, scars will persist across rounds if you survive to the end.',
  component: CheckboxInput,
};
