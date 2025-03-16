import { FeatureIconnedDropdownInput, FeatureWithIcons } from '../dropdowns';

export const preferred_ai_emote_display: FeatureWithIcons<string> = {
  name: 'ИИ на дисплеях',
  description:
    'Если вы являетесь искусственным интеллектом, то изображение по умолчанию отображается на всех дисплеях искусственного интеллекта на станции.',
  component: FeatureIconnedDropdownInput,
};
