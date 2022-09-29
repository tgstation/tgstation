import { multiline } from 'common/string';
import { FeatureToggle, CheckboxInput } from '../base';

export const chat_bankcard: FeatureToggle = {
  name: 'Enable income updates',
  category: 'CHAT',
  description: 'Receive notifications for your bank account.',
  component: CheckboxInput,
};

export const chat_dead: FeatureToggle = {
  name: 'Enable deadchat',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const chat_ghostears: FeatureToggle = {
  name: 'Hear all messages',
  category: 'GHOST',
  description: multiline`
    When enabled, you will be able to hear all speech as a ghost.
    When disabled, you will only be able to hear nearby speech.
  `,
  component: CheckboxInput,
};

export const chat_ghostlaws: FeatureToggle = {
  name: 'Enable law change updates',
  category: 'GHOST',
  description: 'When enabled, be notified of any new law changes as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostpda: FeatureToggle = {
  name: 'Enable PDA notifications',
  category: 'GHOST',
  description: 'When enabled, be notified of any PDA messages as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostradio: FeatureToggle = {
  name: 'Enable radio',
  category: 'GHOST',
  description: 'When enabled, be notified of any radio messages as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostsight: FeatureToggle = {
  name: 'See all emotes',
  category: 'GHOST',
  description: 'When enabled, see all emotes as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostwhisper: FeatureToggle = {
  name: 'See all whispers',
  category: 'GHOST',
  description: multiline`
    When enabled, you will be able to hear all whispers as a ghost.
    When disabled, you will only be able to hear nearby whispers.
  `,
  component: CheckboxInput,
};

export const chat_login_logout: FeatureToggle = {
  name: 'See login/logout messages',
  category: 'GHOST',
  description: 'When enabled, be notified when a player logs in or out.',
  component: CheckboxInput,
};

export const chat_ooc: FeatureToggle = {
  name: 'Enable OOC',
  category: 'CHAT',
  component: CheckboxInput,
};

export const chat_prayer: FeatureToggle = {
  name: 'Listen to prayers',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const chat_pullr: FeatureToggle = {
  name: 'Enable pull request notifications',
  category: 'CHAT',
  description: 'Be notified when a pull request is made, closed, or merged.',
  component: CheckboxInput,
};
