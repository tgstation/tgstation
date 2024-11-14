import {
  CheckboxInput,
  Feature,
  FeatureColorInput,
  FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const asaycolor: Feature<string> = {
  name: 'Admin chat color',
  category: 'ADMIN',
  description: 'The color of your messages in Adminsay.',
  component: FeatureColorInput,
};

export const brief_outfit: Feature<string> = {
  name: 'Brief outfit',
  category: 'ADMIN',
  description: 'The outfit to gain when spawning as the briefing officer.',
  component: FeatureDropdownInput,
};

export const bypass_deadmin_in_centcom: FeatureToggle = {
  name: 'Bypass deadmin options when in CentCom',
  category: 'ADMIN',
  description:
    'Whether or not to always remain an admin when spawned in CentCom.',
  component: CheckboxInput,
};

export const fast_mc_refresh: FeatureToggle = {
  name: 'Enable fast MC stat panel refreshes',
  category: 'ADMIN',
  description:
    'Whether or not the MC tab of the Stat Panel refreshes fast. This is expensive so make sure you need it.',
  component: CheckboxInput,
};

export const ghost_roles_as_admin: FeatureToggle = {
  name: 'Get ghost roles while adminned',
  category: 'ADMIN',
  description: `
    If you de-select this, you will not get any ghost role pop-ups while
    adminned! Every single pop-up WILL never show up for you in an adminned
    state. However, this does not suppress notifications when you are
    a regular player (deadminned).
`,
  component: CheckboxInput,
};

export const comms_notification: FeatureToggle = {
  name: 'Enable comms console sound',
  category: 'ADMIN',
  component: CheckboxInput,
};
