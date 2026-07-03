import {
  CheckboxInput,
  type Feature,
  type FeatureChoiced,
  FeatureColorInput,
  type FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const screentip_pref: FeatureChoiced = {
  name: 'Подсказки на экране',
  category: 'Интерфейс',
  description: `
    Включает подсказки на экране, когда вы наводитесь над объектами.
    Если выбрана "Только с подсказками", подсказки будут появляться, только если
    есть дополнительная информация к ним, например действие на ПКМ.
  `,
  component: FeatureDropdownInput,
};

export const screentip_color: Feature<string> = {
  name: 'Подсказки на экране - цвет',
  category: 'Интерфейс',
  description: `
    Цвет ваших подсказок на экране при наведении на объект.
  `,
  component: FeatureColorInput,
};

export const screentip_images: FeatureToggle = {
  name: 'Подсказки на экране - изображения',
  category: 'Интерфейс',
  description: `Показывает изображения кнопок мыши при подсказках,
    вместо ЛКМ/ПКМ.`,
  component: CheckboxInput,
};
