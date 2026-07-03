import { CheckboxInput, type FeatureToggle } from '../base';

export const round_start_always_join_current_slot: FeatureToggle = {
  name: 'Игнорировать назначенный слот персонажа для работы в начале раунда',
  category: 'Геймплей',
  description:
    'Будет ли присоединение в начале раунда игнорировать назначенный слот персонажа для работы и всегда использовать текущий выбранный слот.',
  component: CheckboxInput,
};

export const late_join_always_current_slot: FeatureToggle = {
  name: 'Игнорировать назначенный слот персонажа для работы при позднем присоединении',
  category: 'Геймплей',
  description:
    'Будет ли присоединение после начала раунда игнорировать назначенный слот персонажа для работы и всегда использовать текущий выбранный слот.',
  component: CheckboxInput,
};
