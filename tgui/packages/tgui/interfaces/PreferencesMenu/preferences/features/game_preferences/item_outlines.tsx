import { CheckboxInput, FeatureToggle } from '../base';

export const itemoutline_pref: FeatureToggle = {
  name: 'Контуры элементов',
  category: 'Гемплей',
  description:
    'Если эта функция включена, при наведении курсора мыши на элементы будут выделены их контуры.',
  component: CheckboxInput,
};
