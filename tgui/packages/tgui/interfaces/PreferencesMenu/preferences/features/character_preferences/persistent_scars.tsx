import { CheckboxInput, FeatureToggle } from '../base';

export const persistent_scars: FeatureToggle = {
  name: 'Стойкие шрамы',
  description:
    'Если этот флажок установлен, шрамы будут сохраняться на протяжении всех раундов, если вы доживете до конца.',
  component: CheckboxInput,
};
