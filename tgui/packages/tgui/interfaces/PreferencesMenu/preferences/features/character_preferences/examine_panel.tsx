import { type Feature, FeatureTextInput } from '../base';

export const flavor_text: Feature<string> = {
  name: 'Описание внешности',
  description: 'Опишите вашего персонажа!',
  component: FeatureTextInput,
};

export const silicon_flavor_text: Feature<string> = {
  name: 'Описание внешности (Синтетик)',
  description: 'Опишите вашего синтетика!',
  component: FeatureTextInput,
};
