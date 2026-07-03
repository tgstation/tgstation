import { CheckboxInput, type FeatureToggle } from '../base';

export const buttons_locked: FeatureToggle = {
  name: 'Заблокировать кнопки действий',
  category: 'Геймплей',
  description: 'Запрещает перемещать кнопки действий.',
  component: CheckboxInput,
};
