import {
  CheckboxInput,
  FeatureNumberInput,
  type FeatureNumeric,
  type FeatureToggle,
} from '../base';

export const chat_on_map: FeatureToggle = {
  name: 'Рунчат: включить',
  category: 'Рунчат',
  description: 'Тест сообщений будет появляться над головами.',
  component: CheckboxInput,
};

export const see_chat_non_mob: FeatureToggle = {
  name: 'Рунчат: включить для объектов',
  category: 'Рунчат',
  description: 'Текст сообщений будет появляться над объектами.',
  component: CheckboxInput,
};

export const chat_on_ghosts: FeatureToggle = {
  name: 'Enable Runechat on ghosts',
  category: 'RUNECHAT',
  description: 'Chat messages will show above ghosts when they speak.',
  component: CheckboxInput,
};

export const see_rc_emotes: FeatureToggle = {
  name: 'Рунчат: включить для эмоций',
  category: 'Рунчат',
  description: 'Текст эмоций будет повляться над головами.',
  component: CheckboxInput,
};

export const max_chat_length: FeatureNumeric = {
  name: 'Рунчат: максимальная длина',
  category: 'Рунчат',
  description: 'Максимальная длина, показываемая рунчатом.',
  component: FeatureNumberInput,
};
