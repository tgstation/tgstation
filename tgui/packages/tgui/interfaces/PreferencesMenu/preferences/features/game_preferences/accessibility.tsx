import { CheckboxInput, FeatureToggle } from '../base';

export const darkened_flash: FeatureToggle = {
  name: 'Включение затемнение вспышек',
  category: 'Спец.Возможности',
  description: `
      При переключении режима мигания экран будет темным, а неярким.
    `,
  component: CheckboxInput,
};

export const screen_shake_darken: FeatureToggle = {
  name: 'Затемнить при дрожании экрана',
  category: 'Спец.Возможности',
  description: `
      При включении этого параметра дрожание экрана приведет к затемнению экрана.
    `,
  component: CheckboxInput,
};
