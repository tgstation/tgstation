import { CheckboxInputInverse, FeatureToggle } from '../base';

export const hotkeys: FeatureToggle = {
  name: 'Классические хоткеи',
  category: 'Гемплей',
  description:
    'Когда эта функция включена, вы вернетесь к прежним горячим клавишам, используя панель ввода, а не всплывающие окна.',
  component: CheckboxInputInverse,
};
