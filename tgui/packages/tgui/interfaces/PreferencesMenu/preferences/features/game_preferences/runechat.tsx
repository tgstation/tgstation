import {
  CheckboxInput,
  FeatureNumberInput,
  FeatureNumeric,
  FeatureToggle,
} from '../base';

export const chat_on_map: FeatureToggle = {
  name: 'Включить рунный чат',
  category: 'Рунный чат',
  description: 'Сообщения чата будут отображаться над заголовками.',
  component: CheckboxInput,
};

export const see_chat_non_mob: FeatureToggle = {
  name: 'Включить рунный чат для объектов',
  category: 'Рунный чат',
  description:
    'Сообщения чата будут отображаться над объектами, когда они будут говорить.',
  component: CheckboxInput,
};

export const see_rc_emotes: FeatureToggle = {
  name: 'Включить эмоции в рунном чате',
  category: 'Рунный чат',
  description: 'Эмоции будут отображаться над головами.',
  component: CheckboxInput,
};

export const max_chat_length: FeatureNumeric = {
  name: 'Максимальная продолжительность чата',
  category: 'Рунный чат',
  description: 'Максимальная длина, которая будет отображаться в рунном чате.',
  component: FeatureNumberInput,
};
