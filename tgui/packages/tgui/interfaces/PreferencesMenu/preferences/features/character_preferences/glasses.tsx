import { FeatureIconnedDropdownInput, FeatureWithIcons } from '../base';

export const glasses: FeatureWithIcons<string> = {
  name: 'Glasses',
  description: 'The type of glasses you will spawn with.',
  component: FeatureIconnedDropdownInput,
};
