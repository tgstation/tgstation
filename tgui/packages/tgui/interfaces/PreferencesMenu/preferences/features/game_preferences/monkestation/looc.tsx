import {
  CheckboxInput,
  FeatureToggle,
  FeatureChoiced,
  FeatureDropdownInput,
} from '../../base';

export const see_looc_on_map: FeatureToggle = {
  name: 'Enable LOOC Runechat',
  category: 'RUNECHAT',
  description: 'LOOC messages will show above heads.',
  component: CheckboxInput,
};

export const admin_hear_looc: FeatureChoiced = {
  name: 'LOOC Omnipotence',
  category: 'ADMIN',
  description: 'When to show non-local LOOC messages.',
  component: FeatureDropdownInput,
};
