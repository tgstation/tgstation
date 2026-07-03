import { CheckboxInputInverse, type FeatureToggle } from '../base';

export const hotkeys: FeatureToggle = {
  name: 'Классические горячие клавиши',
  category: 'Геймплей',
  description:
    'Возвращает к старым горячим клавишам, которые используют полосу ввода, а не всплывающие окна.',
  component: CheckboxInputInverse,
};
