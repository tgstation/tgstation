import { CheckboxInput, type FeatureToggle } from '../base';

export const itemoutline_pref: FeatureToggle = {
  name: 'Контуры предметов',
  category: 'Геймплей',
  description: 'Показывать контур предметов при наведении на них.',
  component: CheckboxInput,
};
