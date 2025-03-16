import { CheckboxInput, FeatureToggle } from '../base';

export const multiz_parallax: FeatureToggle = {
  name: 'Включить параллакс с несколькими точками Z',
  category: 'Гемплей',
  description:
    'Включите параллакс с несколькими углами для получения 3D-эффекта.',
  component: CheckboxInput,
};
