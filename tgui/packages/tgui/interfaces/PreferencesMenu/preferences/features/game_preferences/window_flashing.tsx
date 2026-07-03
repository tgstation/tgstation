import { CheckboxInput, type FeatureToggle } from '../base';

export const windowflashing: FeatureToggle = {
  name: 'Включить мигание окна',
  category: 'Интерфейс',
  description: `
    Важные события в игре заставят иконку игры мигать
    на панели задач.
  `,
  component: CheckboxInput,
};
