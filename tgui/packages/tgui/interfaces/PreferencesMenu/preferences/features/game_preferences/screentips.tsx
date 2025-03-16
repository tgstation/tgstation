import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureColorInput,
  FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const screentip_color: Feature<string> = {
  name: 'Экранные подсказки: цвет экранных подсказок',
  category: 'Интерфейс',
  description: `
    Цвет экранных подсказок, текст, который вы видите при наведении курсора на что-либо.
  `,
  component: FeatureColorInput,
};

export const screentip_images: FeatureToggle = {
  name: 'Всплывающие подсказки: разрешить использование изображений',
  category: 'Интерфейс',
  description: `Когда эта функция включена, в экранных подсказках используются изображения
    кнопок мыши, а не LMB/RMB в юанях.`,
  component: CheckboxInput,
};

export const screentip_pref: FeatureChoiced = {
  name: 'Всплывающие подсказки: включить всплывающие подсказки',
  category: 'Интерфейс',
  description: `
    Включает экранные подсказки, текст, который вы видите при наведении курсора на что-либо.
    Если установлено значение "Только с подсказками", будет отображаться только при наличии дополнительной информации,
    помимо названия, например, при щелчке правой кнопкой мыши.
  `,
  component: FeatureDropdownInput,
};
