import {
  CheckboxInput,
  type Feature,
  FeatureNumberInput,
  type FeatureToggle,
} from '../base';

export const enable_tips: FeatureToggle = {
  name: 'Подсказки при наведении: включить',
  category: 'Подсказки',
  description: `
    Показывать подсказки при наведении на объект.
  `,
  component: CheckboxInput,
};

export const tip_delay: Feature<number> = {
  name: 'Подсказки при наведении: задержка (в мс)',
  category: 'Подсказки',
  description: `
    Задержка перед тем, как показать подсказку при наведении на объект?
  `,
  component: FeatureNumberInput,
};
