import { CheckboxInput, type Feature, type FeatureToggle, FeatureSliderInput } from '../base';

export const darkened_flash: FeatureToggle = {
  name: 'Включить затемненные вспышки',
  category: 'Доступность',
  description: `
    Если включено, яркие вспышки теперь будут затемнять
    ваш экран.
  `,
  component: CheckboxInput,
};

export const screen_shake_darken: FeatureToggle = {
  name: 'Замена дрожи экрана затемнением',
  category: 'Доступность',
  description: `
      Если включено, дрожь экрана будет заменена затемнением экрана.
    `,
  component: CheckboxInput,
};

export const remove_double_click: FeatureToggle = {
  name: 'Убрать двойной клик',
  category: 'Доступность',
  description: `
      Если включено, действия, требующие двойного клика, будут предлагать
      альтернативные варианты, что очень удобно, если у вас не очень функциональная мышь.
    `,
  component: CheckboxInput,
};

export const min_recoil_multiplier: Feature<number> = {
  name: 'Cosmetic Recoil Strength',
  category: 'ACCESSIBILITY',
  description: `
      Modifies the strength of cosmetic recoil's effect on your camera.
      0 will disable cosmetic recoil entirely, though mechanical recoil will be unaffected.
    `,
  component: FeatureSliderInput,
};

export const stair_indicator: FeatureToggle = {
  name: 'Enable stair indicator',
  category: 'ACCESSIBILITY',
  description: `
      When toggled, staircases will have a visual indicator showing which
      direction to walk to transition floors.
    `,
  component: CheckboxInput,
};

export const twelve_hour: FeatureToggle = {
  name: 'Twelve-Hour Clock',
  category: 'ACCESSIBILITY',
  description: `
      When toggled, will replace many instances of real-world time with AM/PM instead.
    `,
  component: CheckboxInput,
};

