import { CheckboxInput, FeatureToggle } from '../base';

export const buttons_locked: FeatureToggle = {
  name: 'Кнопки блокировки действий',
  category: 'Гемплей',
  description:
    'Когда эта функция включена, кнопки действий будут заблокированы на своих местах.',
  component: CheckboxInput,
};
