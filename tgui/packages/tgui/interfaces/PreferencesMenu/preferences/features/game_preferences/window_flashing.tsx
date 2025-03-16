import { CheckboxInput, FeatureToggle } from '../base';

export const windowflashing: FeatureToggle = {
  name: 'Включить мигание окна',
  category: 'Интерфейс',
  description: `
    При переключении некоторых важных событий значок вашей игры будет мигать в панели
    задач.
  `,
  component: CheckboxInput,
};
