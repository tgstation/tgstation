import {
  CheckboxInput,
  type FeatureToggle,
} from '../base';

export const statpanel_open: FeatureToggle = {
  name: 'Enable stat panel',
  category: 'CHAT',
  description:
    'Whether or not the stat panel will be available even when playing as a role that doesnt need it.',
  component: CheckboxInput,
};
