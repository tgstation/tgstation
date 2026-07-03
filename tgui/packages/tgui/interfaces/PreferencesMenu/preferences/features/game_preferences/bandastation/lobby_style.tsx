import type { Feature } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const lobby_style: Feature<string> = {
  name: 'Стиль лобби',
  category: 'Интерфейс',
  component: FeatureDropdownInput,
};
