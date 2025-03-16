import { CheckboxInput, FeatureToggle } from '../base';

export const typingIndicator: FeatureToggle = {
  name: 'Включить индикаторы набора текста',
  category: 'Гемплей',
  description:
    'Включите индикаторы набора, который показывает, что вы набираете сообщение.',
  component: CheckboxInput,
};
