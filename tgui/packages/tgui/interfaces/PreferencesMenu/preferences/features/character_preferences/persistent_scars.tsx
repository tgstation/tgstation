import { CheckboxInput, type FeatureToggle } from '../base';

export const persistent_scars: FeatureToggle = {
  name: 'Сохранение шрамов',
  description:
    'Если выбрано, то шрамы будут сохраняться между раундами, если вы доживаете до их конца.',
  component: CheckboxInput,
};
