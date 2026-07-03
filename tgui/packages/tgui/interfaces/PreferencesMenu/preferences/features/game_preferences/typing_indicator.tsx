import { CheckboxInput, type FeatureToggle } from '../base';

export const typingIndicator: FeatureToggle = {
  name: 'Включить индикатор печатания',
  category: 'Геймплей',
  description: 'Показывать индикатор печатания, когда вы пишите сообщение.',
  component: CheckboxInput,
};
