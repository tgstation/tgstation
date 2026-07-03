import { CheckboxInput, type FeatureToggle } from '../base';

export const ambientocclusion: FeatureToggle = {
  name: 'Включить Ambient Occlusion',
  category: 'Геймплей',
  description: 'Глобальное затенение, добавляющее легие тени вокруг объектов.',
  component: CheckboxInput,
};
