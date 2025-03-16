import {
  CheckboxInput,
  Feature,
  FeatureNumberInput,
  FeatureToggle,
} from '../base';

export const enable_tips: FeatureToggle = {
  name: 'Включить всплывающие подсказки',
  category: 'Подсказки',
  description: `
    Вы хотите видеть всплывающие подсказки при наведении курсора на элементы?
  `,
  component: CheckboxInput,
};

export const tip_delay: Feature<number> = {
  name: 'Задержка всплывающей подсказки (в миллисекундах)',
  category: 'Подсказки',
  description: `
    Сколько времени должно пройти, чтобы при наведении курсора на элементы появилась всплывающая подсказка?
  `,
  component: FeatureNumberInput,
};
