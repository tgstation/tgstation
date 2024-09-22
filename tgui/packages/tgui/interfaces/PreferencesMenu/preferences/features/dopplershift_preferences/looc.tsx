import { CheckboxInput, FeatureToggle } from '../base';

export const looc_admin_pref: FeatureToggle = {
  name: 'See admin LOOC',
  category: 'ADMIN',
  description:
    'Toggles whether you want to see LOOC anywhere as an admin or not.',
  component: CheckboxInput,
};

export const enable_looc_runechat: FeatureToggle = {
  name: 'Enable LOOC runechat',
  category: 'RUNECHAT',
  description:
    "If TRUE, LOOC will appear above the speaker's head as well as in the chat.",
  component: CheckboxInput,
};
