import { FeatureIconnedDropdownInput, FeatureWithIcons } from '../base';

export const preferred_ai_core_display: FeatureWithIcons<string> = {
  name: 'AI core display',
  description: 'Can be changed in-round.',
  component: FeatureIconnedDropdownInput,
};
