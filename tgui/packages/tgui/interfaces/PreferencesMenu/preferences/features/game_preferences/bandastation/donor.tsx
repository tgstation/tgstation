import { CheckboxInput, type FeatureToggle } from '../../base';

export const donor_public: FeatureToggle = {
  name: 'Отображать статус бустера',
  category: 'Чат',
  description:
    'Если включено, в OOC чате будет отображаться значок тира подписки.',
  component: CheckboxInput,
};
