import { FeatureIconnedDropdownInput, FeatureWithIcons } from '../dropdowns';

export const preferred_ai_hologram_display: FeatureWithIcons<string> = {
  name: 'Голограмма ИИ',
  description:
    'Голографическая форма, которую вы будете принимать при использовании голопада.',
  component: FeatureIconnedDropdownInput,
};
