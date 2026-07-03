import { CheckboxInput, type FeatureToggle } from '../base';

export const widescreenpref: FeatureToggle = {
  name: 'Включить широкоэкранный режим',
  category: 'Интерфейс',
  component: CheckboxInput,
};

export const fullscreen_mode: FeatureToggle = {
  name: 'Включить полноэкранный режим',
  category: 'Интерфейс',
  description:
    'Включает полноэкранный режим игры, также можно включить с помощью F11.',
  component: CheckboxInput,
};
