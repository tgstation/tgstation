import { Feature } from '../base';
import { FeatureTextInput } from '../base_bandastation';

export const flavor_text: Feature<string> = {
  name: 'Flavor Text',
  description: 'Опишите вашего персонажа!',
  component: FeatureTextInput,
};

export const silicon_flavor_text: Feature<string> = {
  name: 'Flavor Text (Silicon)',
  description: 'Опишите вашего силикона!',
  component: FeatureTextInput,
};
