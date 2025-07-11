import {
  CheckboxInput,
  FeatureNumberInput,
  type FeatureNumeric,
  type FeatureToggle,
} from '../base';

export const chat_on_map: FeatureToggle = {
  name: 'Enable Runechat',
  category: 'RUNECHAT',
  description: 'Chat messages will show above heads.',
  component: CheckboxInput,
};

export const see_chat_non_mob: FeatureToggle = {
  name: 'Enable Runechat on objects',
  category: 'RUNECHAT',
  description: 'Chat messages will show above objects when they speak.',
  component: CheckboxInput,
};

export const see_rc_emotes: FeatureToggle = {
  name: 'Enable Runechat emotes',
  category: 'RUNECHAT',
  description: 'Emotes will show above heads.',
  component: CheckboxInput,
};

export const max_chat_length: FeatureNumeric = {
  name: 'Max chat length',
  category: 'RUNECHAT',
  description: 'The maximum length a Runechat message will show as.',
  component: FeatureNumberInput,
};
