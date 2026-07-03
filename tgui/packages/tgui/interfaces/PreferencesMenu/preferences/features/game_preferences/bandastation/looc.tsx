import { CheckboxInput, type FeatureToggle } from '../../base';

export const looc_admin_pref: FeatureToggle = {
  name: 'Слышать LOOC чат',
  category: 'Админ',
  description:
    'Если включено, вы будете получать LOOC сообщения от всех мобов.',
  component: CheckboxInput,
};
