import type { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const preferred_map: Feature<string> = {
  name: 'Предпочтительная карта',
  category: 'Геймплей',
  description: `
    Предпочитать эту карту при ротации карт.
    Это влияет только тогда, когда вы не проголосовали
    за выбор карты.
  `,
  component: FeatureDropdownInput,
};
