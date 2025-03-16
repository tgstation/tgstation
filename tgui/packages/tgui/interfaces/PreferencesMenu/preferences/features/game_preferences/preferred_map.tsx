import { Feature } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const preferred_map: Feature<string> = {
  name: 'Предпочитаемая карта',
  category: 'Гемплей',
  description: `
    Во время ротации карты предпочитайте, чтобы была выбрана именно эта карта.
    Это не влияет на голосование по карте, только случайная ротация, когда голосование
    не проводится.
  `,
  component: FeatureDropdownInput,
};
