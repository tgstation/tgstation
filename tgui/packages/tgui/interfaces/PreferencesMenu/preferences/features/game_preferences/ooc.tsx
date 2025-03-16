import { Feature, FeatureColorInput } from '../base';

export const ooccolor: Feature<string> = {
  name: 'Цвет OOC',
  category: 'Чат',
  description: 'Цвет ваших сообщений OOC.',
  component: FeatureColorInput,
};
