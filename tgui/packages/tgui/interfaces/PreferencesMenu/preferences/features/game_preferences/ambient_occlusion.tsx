import { CheckboxInput, FeatureToggle } from '../base';

export const ambientocclusion: FeatureToggle = {
  name: 'Включить внешнюю окклюзию',
  category: 'Гемплей',
  description:
    'Включите внешнюю маскировку, создавайте легкие тени вокруг персонажей.',
  component: CheckboxInput,
};
